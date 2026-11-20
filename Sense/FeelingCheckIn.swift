import SwiftUI

struct FeelingCheckIn: View {
    @Binding var selectedFeeling: Int

    private let feelings: [FeelingOption] = [
        FeelingOption(title: "Erschöpft", symbol: "moon.zzz.fill", detail: "Erholung darf heute Vorrang haben.", tint: .indigo),
        FeelingOption(title: "Müde", symbol: "cloud.fill", detail: "Plane dir zwischendurch kleine Pausen ein.", tint: .cyan),
        FeelingOption(title: "Neutral", symbol: "circle.lefthalf.filled", detail: "Nimm den Tag Schritt für Schritt.", tint: .secondary),
        FeelingOption(title: "Okay", symbol: "sun.haze.fill", detail: "Du findest deinen eigenen Rhythmus.", tint: .orange),
        FeelingOption(title: "Leicht", symbol: "sun.max.fill", detail: "Du fühlst dich heute energiegeladen.", tint: .yellow)
    ]

    private var currentFeeling: FeelingOption {
        feelings[min(max(selectedFeeling, 0), feelings.count - 1)]
    }

    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(selectedFeeling) },
            set: { selectedFeeling = Int($0.rounded()) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Wie fühlst du dich?")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(selectedFeeling + 1) von 5")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            HStack(spacing: 12) {
                Image(systemName: currentFeeling.symbol)
                    .font(.system(size: 21, weight: .medium))
                    .symbolEffect(.bounce, value: selectedFeeling)
                    .foregroundStyle(currentFeeling.tint)
                    .frame(width: 48, height: 48)
                    .background(currentFeeling.tint.opacity(0.13), in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(currentFeeling.title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                    Text(currentFeeling.detail)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .contentTransition(.opacity)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 2)
            .accessibilityElement(children: .combine)

            Slider(
                value: sliderValue,
                in: 0...Double(feelings.count - 1),
                step: 1,
                label: { Text("Dein Gefühl") },
                minimumValueLabel: {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                },
                maximumValueLabel: {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            )
            .tint(currentFeeling.tint)
            .accessibilityValue(currentFeeling.title)
        }
        .healthCard()
        .animation(.snappy(duration: 0.28), value: selectedFeeling)
        .sensoryFeedback(.selection, trigger: selectedFeeling)
    }
}

private struct FeelingOption {
    let title: String
    let symbol: String
    let detail: String
    let tint: Color
}
