import AppKit
import Combine
import CoreGraphics
import Vision

/// 截取主显示器画面并用 Vision 识别二维码；需「屏幕录制」权限。由用户按键或按钮触发单次扫描。
final class ScreenQRScanner: ObservableObject {
    @Published var statusText: String = ""
    @Published var lastError: String?
    @Published private(set) var isScanning: Bool = false

    private var lastHandledPayload: String?

    var onOtpAuthPayload: ((String) -> Void)?

    /// 执行一次截屏 + 识别（扫描进行中时忽略重复请求）。
    func scanOnce() {
        guard !isScanning else { return }
        lastError = nil
        statusText = L10n.ScannerStatus.scanning
        isScanning = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            defer {
                DispatchQueue.main.async {
                    self.isScanning = false
                }
            }

            guard let image = Self.captureMainDisplay() else {
                DispatchQueue.main.async {
                    self.lastError = L10n.ScannerStatus.screenDenied
                    self.statusText = L10n.ScannerStatus.needPermission
                }
                return
            }

            var visionError: Error?
            var otpauthPayload: String?

            let request = VNDetectBarcodesRequest { request, error in
                if let error {
                    visionError = error
                    return
                }
                guard let observations = request.results as? [VNBarcodeObservation] else { return }
                for obs in observations where obs.symbology == .qr {
                    guard let payload = obs.payloadStringValue?.trimmingCharacters(in: .whitespacesAndNewlines),
                          !payload.isEmpty else { continue }
                    if payload.lowercased().hasPrefix("otpauth://") {
                        otpauthPayload = payload
                        return
                    }
                }
            }
            request.symbologies = [.qr]

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.lastError = error.localizedDescription
                    self.statusText = L10n.ScannerStatus.failed
                }
                return
            }

            DispatchQueue.main.async {
                if let err = visionError {
                    self.lastError = err.localizedDescription
                    self.statusText = L10n.ScannerStatus.failed
                    return
                }
                if let payload = otpauthPayload {
                    self.lastError = nil
                    self.handlePayload(payload)
                } else {
                    self.statusText = L10n.ScannerStatus.noQr
                }
            }
        }
    }

    private func handlePayload(_ payload: String) {
        if payload == lastHandledPayload { return }
        lastHandledPayload = payload
        statusText = L10n.ScannerStatus.recognized
        onOtpAuthPayload?(payload)
        NSSound.beep()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self else { return }
            if self.lastHandledPayload == payload {
                self.lastHandledPayload = nil
            }
        }
    }

    private static func captureMainDisplay() -> CGImage? {
        let id = CGMainDisplayID()
        return CGDisplayCreateImage(id)
    }
}
