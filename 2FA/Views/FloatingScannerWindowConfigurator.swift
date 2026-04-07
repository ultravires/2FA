import AppKit
import SwiftUI

/// 将所在窗口设为浮动置顶，并允许透明背景透出桌面（便于对准屏幕上的二维码）。
struct FloatingScannerWindowConfigurator: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        context.coordinator.attach(to: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.attach(to: nsView)
    }

    final class Coordinator {
        private weak var observedView: NSView?

        func attach(to view: NSView) {
            observedView = view
            DispatchQueue.main.async { [weak self] in
                self?.configure(view.window)
            }
        }

        private func configure(_ window: NSWindow?) {
            guard let window else { return }
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.isMovableByWindowBackground = false
        }
    }
}
