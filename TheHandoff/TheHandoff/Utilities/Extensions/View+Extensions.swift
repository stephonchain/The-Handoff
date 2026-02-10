import SwiftUI

struct CardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardShadow() -> some View {
        modifier(CardShadow())
    }
}
