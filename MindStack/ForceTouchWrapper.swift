import SwiftUI
import AppKit

// Custom NSView capable of detecting Force Touch
class ForceTouchableView: NSView {
    static let grain: Float = 0.1
    
    var onPressureChange: ((Float, Int) -> Void)?
    var onScrollX: ((CGFloat) -> Void)?
    
    override var acceptsFirstResponder: Bool { true }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.pressureConfiguration = NSPressureConfiguration(pressureBehavior: .primaryDeepClick)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pressureChange(with event: NSEvent) {
        onPressureChange?(event.stage > 1 ? 1 : event.pressure, event.stage)
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        if (abs(event.scrollingDeltaY) < abs(event.scrollingDeltaX)) {
            onScrollX?(event.scrollingDeltaX)
        }
    }
}

// NSViewRepresentable wrapper for ForceTouchableView
struct ForceTouchView: NSViewRepresentable {
    var pressureChanged: (Float, Int) -> Void
    var scrollX: ((CGFloat) -> Void)?
    
    func makeNSView(context: Context) -> ForceTouchableView {
        let view = ForceTouchableView(frame: .zero)
        view.onPressureChange = pressureChanged
        view.onScrollX = scrollX
        return view
    }
    
    func updateNSView(_ nsView: ForceTouchableView, context: Context) {}
}
