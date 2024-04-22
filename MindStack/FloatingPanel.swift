import SwiftUI

/// An NSPanel subclass that implements floating panel traits.
class FloatingPanel<Content: View>: NSPanel {
    
    @Binding var isPresented: Bool
    @Binding var isPinned: Bool
    
    init(view: () -> Content,
         contentRect: NSRect,
         backing: NSWindow.BackingStoreType = .buffered,
         defer flag: Bool = false,
         isPresented: Binding<Bool>,
         isPinned: Binding<Bool> = .constant(false)
    ) {
        /// Initialize the binding variable by assigning the whole value via an underscore
        self._isPresented = isPresented
        self._isPinned = isPinned
        
        /// Init the window as usual
        super.init(contentRect: contentRect,
                   styleMask: [.nonactivatingPanel, .titled],
                   backing: backing,
                   defer: flag)
        
        /// Allow the panel to be on top of other windows
        isFloatingPanel = true
        level = .floating
        
        /// Allow the pannel to be overlaid in a fullscreen space
        collectionBehavior = collectionBehavior.union([.fullScreenAuxiliary, .moveToActiveSpace, .auxiliary])
        
        /// Don't show a window title, even if it's set
        titleVisibility = .hidden
        titlebarAppearsTransparent = false
        titlebarSeparatorStyle = .automatic
        
        
        /// Since there is no title bar make the window moveable by dragging on the background
//        isMovableByWindowBackground = true
        
        /// Hide when unfocused
        hidesOnDeactivate = false
        
        /// Hide all traffic light buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        /// Sets animations accordingly
        animationBehavior = .utilityWindow
        
        /// Set the content view.
        /// The safe area is ignored because the title bar still interferes with the geometry
        contentView = NSHostingView(rootView: view()
            .ignoresSafeArea()
            .environment(\.floatingPanel, self))
    }
    
    /// Close automatically when out of focus, e.g. outside click
    override func resignMain() {
        super.resignMain()
        if !isPinned {
            close()
        }
    }
    
    /// Close and toggle presentation, so that it matches the current state of the panel
    override func close() {
        super.close()
        isPresented = false
    }
    
    /// `canBecomeKey` and `canBecomeMain` are both required so that text inputs inside the panel can receive focus
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}



private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}

extension EnvironmentValues {
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}

extension NSPanel { // 1
    
    struct Position {
        // 2
        static let defaultPadding: CGFloat = 16
        // 3
        var vertical: Vertical
        var horizontal: Horizontal
        var padding = Self.defaultPadding
    }
}

extension NSPanel.Position {
    
    enum Horizontal {
        case left, center, right
    }
    
    enum Vertical {
        case top, center, bottom
    }
}

extension NSPanel.Position.Vertical {
    
    func valueFor(
        screenRange: Range<CGFloat>,
        height: CGFloat,
        padding: CGFloat)
    -> CGFloat {
        switch self {
        case .top: return screenRange.upperBound - height - padding
        case .center: return (screenRange.upperBound + screenRange.lowerBound - height) / 2
        case .bottom: return screenRange.lowerBound + padding
        }
    }
}


extension NSPanel.Position.Horizontal {
    
    func valueFor(
        screenRange: Range<CGFloat>,
        width: CGFloat,
        padding: CGFloat)
    -> CGFloat {
        switch self {
        case .right: return screenRange.upperBound - width - padding
        case .center: return (screenRange.upperBound + screenRange.lowerBound - width) / 2
        case .left: return screenRange.lowerBound + padding
        }
    }
}

extension NSPanel.Position {
    
    func value(forWindow windowRect: CGRect, inScreen screenRect: CGRect)
    -> CGPoint {
        let xPosition = horizontal.valueFor(
            screenRange: screenRect.minX..<screenRect.maxX,
            width: windowRect.width,
            padding: padding
        )
        
        let yPosition = vertical.valueFor(
            screenRange: screenRect.minY..<screenRect.maxY,
            height: windowRect.height,
            padding: padding
        )
        
        return CGPoint(x: xPosition, y: yPosition)
    }
}

extension NSPanel {
    
    func set(_ position: Position, in screen: NSScreen?) {
        guard let visibleFrame = (screen ?? self.screen)?.visibleFrame else { return }
        let origin = position.value(forWindow: frame, inScreen: visibleFrame)
        setFrameOrigin(origin)
    }
    
    func setPosition(
        vertical: Position.Vertical,
        horizontal: Position.Horizontal,
        padding: CGFloat = Position.defaultPadding,
        screen: NSScreen? = nil
    ) {
        set(
            Position(
                vertical: vertical,
                horizontal: horizontal,
                padding: padding
            ),
            in: screen
        )
    }
}
