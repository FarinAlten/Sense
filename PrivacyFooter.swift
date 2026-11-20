import SwiftUI

struct PrivacyFooter: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock.shield")
            Text("Deine Gesundheitsdaten bleiben privat")
        }
        .font(.system(size: 10))
        .foregroundStyle(.primary.opacity(0.32))
        .frame(maxWidth: .infinity)
        .padding(.top, 1)
    }
}
