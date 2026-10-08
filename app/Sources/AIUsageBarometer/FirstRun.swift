import AppKit

// 初回だけ出す。説明文は書かない。実物を3つ並べて、押したものがそのまま採用される。
// OK ボタンは置かない。押した瞬間が決定で、あとからメニューでいくらでも変えられる。
final class FirstRunWindow: NSWindow {
    private let onPick: (String) -> Void

    static var needed: Bool {
        let keys = ["p_menu", "p_dock", "p_float", "presence"]
        return !keys.contains { FileManager.default.fileExists(atPath: Settings.dir + "/" + $0) }
    }

    init(rows: [Row], pick: @escaping (String) -> Void) {
        onPick = pick
        super.init(contentRect: NSRect(x: 0, y: 0, width: 420, height: 330),
                   styleMask: [.titled, .closable, .fullSizeContentView],
                   backing: .buffered,
                   defer: false)
        title = "AI Usage Barometer"
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        backgroundColor = NSColor(srgbRed: 0.09, green: 0.10, blue: 0.12, alpha: 1.0)

        let content = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 330))
        let heading = NSTextField(labelWithString: "Where should it live?")
        heading.font = NSFont.systemFont(ofSize: 17, weight: .semibold)
        heading.textColor = Gauge.fg
        heading.frame = NSRect(x: 24, y: 282, width: 372, height: 24)
        content.addSubview(heading)

        let options: [(String, String)] = [
            ("p_menu", "Menu bar"),
            ("p_dock", "Dock icon"),
            ("p_float", "Floating bar"),
        ]
        var y: CGFloat = 196
        for (key, title) in options {
            content.addSubview(card(key: key, title: title, rows: rows, y: y))
            y -= 86
        }
        contentView = content
    }

    private func card(key: String, title: String, rows: [Row], y: CGFloat) -> NSView {
        let card = PickCard(frame: NSRect(x: 24, y: y, width: 372, height: 74))
        card.onClick = { [weak self] in self?.onPick(key) }

        // プレビューは本物と同じ向き・同じ寸法で描く。選ぶ前に見えているものと
        // 選んだあとに出るものが違えば、選ばせた意味がない。
        let preview = GaugeView(frame: NSRect(x: 14, y: 8, width: 210, height: 58))
        switch key {
        case "p_menu":
            preview.axis = .horizontal
            preview.metrics = Gauge.menubar
        case "p_dock":
            preview.axis = .vertical
            preview.metrics = Gauge.dock
        default:
            preview.axis = .grouped
            preview.metrics = Gauge.float
        }
        preview.rows = rows
        // プレビューの中のクリックも、カードのクリックとして扱う
        preview.onClick = { [weak self] in self?.onPick(key) }
        card.addSubview(preview)

        let label = NSTextField(labelWithString: title)
        label.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = Gauge.fg
        label.frame = NSRect(x: 240, y: 28, width: 120, height: 18)
        card.addSubview(label)
        return card
    }
}

final class PickCard: NSView {
    var onClick: (() -> Void)?
    private var hovering = false

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds, xRadius: 10, yRadius: 10)
        NSColor(white: hovering ? 0.22 : 0.16, alpha: 1.0).setFill()
        path.fill()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for a in trackingAreas { removeTrackingArea(a) }
        addTrackingArea(NSTrackingArea(rect: bounds,
                                       options: [.mouseEnteredAndExited, .activeAlways],
                                       owner: self,
                                       userInfo: nil))
    }

    override func mouseEntered(with event: NSEvent) {
        hovering = true
        needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        hovering = false
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        onClick?()
    }
}
