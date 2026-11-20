import Charts
import SwiftUI

struct HealthMetricsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Schlaf & Erholung")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text("LETZTE NACHT")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                NavigationLink {
                    HealthCategoryDetailView(category: .sleep, selectedRange: "Woche")
                } label: {
                    HealthMetricCard(
                        title: "Schlaf", value: "7", unit: "42 Min.",
                        symbol: "bed.double.fill", footnote: "96 % Effizienz · 24 Min. unter Ziel",
                        accent: .indigo,
                        bars: [0.34, 0.55, 0.43, 0.73, 0.52, 0.82, 0.61, 0.9, 0.67, 0.48, 0.75, 0.58]
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    HealthCategoryDetailView(category: .heart, selectedRange: "Woche")
                } label: {
                    HealthMetricCard(
                        title: "Erholung", value: "58", unit: "ms HRV",
                        symbol: "waveform.path.ecg", footnote: "Im persönlichen Bereich",
                        accent: .red,
                        bars: [0.52, 0.4, 0.67, 0.55, 0.74, 0.45, 0.83, 0.62, 0.49, 0.7, 0.57, 0.78]
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct HealthMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let symbol: String
    let footnote: String
    let accent: Color
    let bars: [CGFloat]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(accent)
                Spacer(minLength: 4)
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(0.9)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(value)
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .tracking(-1.1)
                    .foregroundStyle(.primary)
                Text(title == "Schlaf" ? "Std." : "ms")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Text(title == "Schlaf" ? unit : "Herzratenvariabilität")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Chart {
                ForEach(bars.indices, id: \.self) { index in
                    BarMark(
                        x: .value("Messung", index),
                        y: .value("Wert", Double(bars[index]))
                    )
                    .foregroundStyle(accent.opacity(index == bars.count - 1 ? 0.9 : 0.45))
                    .cornerRadius(3)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...1)
            .frame(height: 34)
            .accessibilityLabel("\(title), Verlauf der letzten zwölf Messungen")

            Text(footnote)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(height: 24, alignment: .topLeading)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .healthCard(cornerRadius: 22)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
