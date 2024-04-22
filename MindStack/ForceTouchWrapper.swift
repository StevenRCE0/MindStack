import SwiftUI
import AppKit

// Custom NSView capable of detecting Force Touch
class ForceTouchableView: NSView {
    static let grain: Float = 0.1
    
    var onPressureChange: ((Float, Int) -> Void)?
    var handleSwipe: ((NSEvent, Set<NSTouch>?) -> Void)?
    
    override var acceptsFirstResponder: Bool { true }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.pressureConfiguration = NSPressureConfiguration(pressureBehavior: .primaryDeepClick)
        self.allowedTouchTypes = [.indirect]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pressureChange(with event: NSEvent) {
        onPressureChange?(event.stage > 1 ? 1 : event.pressure, event.stage)
        super.pressureChange(with: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        if abs(event.deltaX) > abs(event.deltaY) {
            handleSwipe?(event, nil)
        }
    }
    
    
    private func handleTouches(with event: NSEvent) {
        // Get all `.touching` touches only (includes `.began`, `.moved` & `.stationary`).
        let touches = event.touches(matching: .touching, in: self)
        // Forward them via delegate.
        handleSwipe?(event, touches)
    }
    
    override func touchesBegan(with event: NSEvent) {
        handleTouches(with: event)
    }
    
    override func touchesEnded(with event: NSEvent) {
        handleTouches(with: event)
    }
    
    override func touchesMoved(with event: NSEvent) {
        handleTouches(with: event)
    }
    
    override func touchesCancelled(with event: NSEvent) {
        handleTouches(with: event)
    }
}

// NSViewRepresentable wrapper for ForceTouchableView
struct ForceTouchView: NSViewRepresentable {
    var pressureChanged: (Float, Int) -> Void
    var swipe: ((NSEvent, Set<NSTouch>?) -> Void)?
    
    func makeNSView(context: Context) -> ForceTouchableView {
        let view = ForceTouchableView(frame: .zero)
        view.onPressureChange = pressureChanged
        view.handleSwipe = swipe
        return view
    }
    
    func updateNSView(_ nsView: ForceTouchableView, context: Context) {}
}
