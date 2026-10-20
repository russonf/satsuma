import SwiftUI

enum SatsumaTheme {
    /// User-chosen style: "glass" or "solid".
    static var style: String {
        UserDefaults.standard.string(forKey: "appearance.style") ?? "glass"
    }
}

struct SatsumaBackground: ViewModifier {
    func body(content: Content) -> some View {
        if SatsumaTheme.style == "glass" {
            content.background(.ultraThinMaterial)
        } else {
            content.background(Color(nsColor: .windowBackgroundColor))
        }
    }
}

extension View {
    func satsumaBackground() -> some View { modifier(SatsumaBackground()) }
}
