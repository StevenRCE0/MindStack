import SwiftUI
 
/// Add a  ``FloatingPanel`` to a view hierarchy
fileprivate struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
    /// Determines wheter the panel should be presented or not
    @Binding var isPresented: Bool
    @Binding var isPinned: Bool
 
    /// Determines the starting size of the panel
    var contentRect: CGRect = CGRect(x: 0, y: 0, width: 320, height: 580)
 
    /// Holds the panel content's view closure
    @ViewBuilder let view: () -> PanelContent
 
    /// Stores the panel instance with the same generic type as the view closure
    @State var panel: FloatingPanel<PanelContent>?
 
    func body(content: Content) -> some View {
        content
            .onAppear {
                /// When the view appears, create, center and present the panel if ordered
                panel = FloatingPanel(view: view, contentRect: contentRect, isPresented: $isPresented, isPinned: $isPinned)
                panel?.setPosition(vertical: .center, horizontal: .right)
                if isPresented {
                    present()
                }
            }.onDisappear {
                /// When the view disappears, close and kill the panel
                panel?.close()
            }.onChange(of: isPresented, initial: false) { _, value in
                /// On change of the presentation state, make the panel react accordingly
                if value {
                    present()
                    panel?.setPosition(vertical: .center, horizontal: .right)
                } else {
                    panel?.close()
                }
            }.onChange(of: isPinned, initial: false) { _, value in
                panel?.isPinned = value
                if !value {
                    withAnimation(.easeIn(duration: 0)) {
                        panel?.resignMain()
                        present()
                        isPresented = true
                    }
                }
            }
    }
 
    /// Present the panel and make it the key window
    func present() {
        panel?.orderFront(nil)
        panel?.makeKey()
    }
}

extension View {
    /** Present a ``FloatingPanel`` in SwiftUI fashion
     - Parameter isPresented: A boolean binding that keeps track of the panel's presentation state
     - Parameter contentRect: The initial content frame of the window
     - Parameter content: The displayed content
     **/
    func floatingPanel<Content: View>(isPresented: Binding<Bool>,
                                      isPinned: Binding<Bool> = .constant(false),
                                      contentRect: CGRect = CGRect(x: 0, y: 0, width: 320, height: 580),
                                      @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FloatingPanelModifier(isPresented: isPresented, isPinned: isPinned, contentRect: contentRect, view: content ))
    }
}

