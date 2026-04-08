#!/usr/bin/env swift
import AppKit
import Foundation

/// 纯代码绘制「2FA」圆角方块图标，导出为 macOS AppIcon.iconset 所需 PNG。
enum AppIconPalette {
    static let fill = NSColor(calibratedRed: 0.2, green: 0.45, blue: 0.95, alpha: 1)
}

func fittedFont(text: String, maxWidth: CGFloat, maxPointSize: CGFloat) -> NSFont {
    var size = maxPointSize
    while size > 3 {
        let font = NSFont.systemFont(ofSize: size, weight: .heavy)
        let w = (text as NSString).size(withAttributes: [.font: font]).width
        if w <= maxWidth { return font }
        size -= 0.5
    }
    return NSFont.systemFont(ofSize: 3, weight: .heavy)
}

func pngData(pixels: Int) -> Data? {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 32
    ) else { return nil }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high

    let px = CGFloat(pixels)
    let inset = px * 0.08
    let inner = NSRect(x: inset, y: inset, width: px - inset * 2, height: px - inset * 2)
    let corner = px * 0.2
    let path = NSBezierPath(roundedRect: inner, xRadius: corner, yRadius: corner)
    AppIconPalette.fill.setFill()
    path.fill()

    let text = "2FA"
    let maxFont = px * 0.36
    let font = fittedFont(text: text, maxWidth: inner.width * 0.92, maxPointSize: maxFont)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white,
    ]
    let textSize = (text as NSString).size(withAttributes: attrs)
    let origin = NSPoint(
        x: (px - textSize.width) / 2,
        y: (px - textSize.height) / 2 - px * 0.02
    )
    (text as NSString).draw(at: origin, withAttributes: attrs)

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

let entries: [(filename: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

let outRoot: URL = {
    if CommandLine.arguments.count > 1 {
        return URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    }
    return URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        .appendingPathComponent("Support/.generated", isDirectory: true)
}()

let iconset = outRoot.appendingPathComponent("AppIcon.iconset", isDirectory: true)
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

for entry in entries {
    guard let data = pngData(pixels: entry.pixels) else {
        fputs("Failed to render \(entry.filename)\n", stderr)
        exit(1)
    }
    let url = iconset.appendingPathComponent(entry.filename)
    try data.write(to: url)
}

let icnsURL = outRoot.appendingPathComponent("AppIcon.icns")
try? FileManager.default.removeItem(at: icnsURL)

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", iconset.path, "-o", icnsURL.path]
try iconutil.run()
iconutil.waitUntilExit()
guard iconutil.terminationStatus == 0 else {
    fputs("iconutil failed\n", stderr)
    exit(1)
}

print("Wrote \(icnsURL.path)")
