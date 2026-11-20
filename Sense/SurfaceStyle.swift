import SwiftUI

extension View {
    func healthCard(cornerRadius: CGFloat = 24) -> some View {
        padding(18)
            .background(
                Color(uiColor: .secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
    }

    func healthPanel(cornerRadius: CGFloat = 20) -> some View {
        background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
}
