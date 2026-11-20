import SwiftUI

struct DashboardHeader: View {
    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: "Guten Morgen."
        case 12..<18: "Guten Tag."
        default: "Guten Abend."
        }
    }

    private var date: String {
        Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "de_DE")))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(greeting)
                .font(.system(size: 34, weight: .semibold))
                .tracking(-0.7)
                .foregroundStyle(.primary)

            HStack(spacing: 7) {
                Text(date)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Spacer()
                Label("Beispieldaten", systemImage: "heart.text.square")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
