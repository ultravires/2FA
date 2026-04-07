import Combine
import Foundation

/// 主窗口顶部 toast；由 `ContentView` 展示，扫码窗口等通过 `environmentObject` 触发。
final class ToastManager: ObservableObject {
    @Published private(set) var message: String?

    private var hideWorkItem: DispatchWorkItem?

    func show(_ text: String, duration: TimeInterval = 2.5) {
        hideWorkItem?.cancel()
        message = text
        let item = DispatchWorkItem { [weak self] in
            self?.message = nil
        }
        hideWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: item)
    }

    func dismiss() {
        hideWorkItem?.cancel()
        message = nil
    }
}
