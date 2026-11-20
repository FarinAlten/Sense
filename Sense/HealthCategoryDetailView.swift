import Charts
import SwiftUI

struct HealthCategoryDetailView: View {
    @State private var isShowingSettings = false
    let category: HealthCategory
    let selectedRange: String

    private var value: String {
        switch category {
        case .sleep:
            switch selectedRange {
            case "Tag": "7 Std. 42 Min."
            case "Monat": "7 Std. 30 Min."
            case "6 Mon.": "7 Std. 24 Min."
            default: "7 Std. 36 Min."
            }
        case .heart:
            switch selectedRange {
            case "Tag": "58 ms"
            case "Monat": "54 ms"
            case "6 Mon.": "55 ms"
            default: "56 ms"
            }
        case .activity:
            switch selectedRange {
            case "Tag": "10.230"
            case "Monat": "8.100"
            case "6 Mon.": "7.950"
            default: "8.420"
            }
        case .mindfulness:
            switch selectedRange {
            case "Tag": "12 Min."
            case "Monat": "16 Min."
            case "6 Mon.": "15 Min."
            default: "18 Min."
            }
        case .body: "68,4 kg"
        }
    }

    private var periodDescription: String {
        switch selectedRange {
        case "Tag": "Heute"
        case "Monat": "Dieser Monat"
        case "6 Mon.": "Letzte 6 Monate"
        default: "Diese Woche"
        }
    }

    private var measureLabel: String {
        switch category {
        case .sleep: "DURCHSCHNITT PRO NACHT"
        case .heart: "HERZFREQUENZVARIABILITÄT · MITTEL"
        case .activity: "SCHRITTE PRO TAG · MITTEL"
        case .mindfulness: "ACHTSAMKEIT PRO TAG · MITTEL"
        case .body: "LETZTE MESSUNG"
        }
    }

    private var description: String {
        switch category {
        case .sleep: "Schlaf gibt deinem Körper Zeit zur Regeneration. Dauer und Regelmäßigkeit zusammen zeigen, wie sich deine Nächte entwickeln."
        case .heart: "Die Herzfrequenzvariabilität beschreibt die kleinen Abstände zwischen Herzschlägen. Betrachte Veränderungen am besten im Vergleich zu deinem eigenen Verlauf."
        case .activity: "Deine Schritte zeigen Bewegung im Alltag. Auch kurze Wege und kleine Pausen summieren sich über den Tag."
        case .mindfulness: "Erfasste Achtsamkeitsminuten helfen dir, ruhige Momente im Alltag sichtbar zu machen."
        case .body: "Körpermessungen sind Momentaufnahmen. Aussagekräftiger ist ein längerfristiger Verlauf unter ähnlichen Bedingungen."
        }
    }

    private var secondaryMetrics: [(String, String)] {
        switch category {
        case .sleep: [("Schlafeffizienz", "91 %"), ("Zeit im Bett", "8 Std. 21 Min."), ("Tiefschlaf", "1 Std. 34 Min."), ("REM-Schlaf", "1 Std. 48 Min."), ("Regelmäßigkeit", "Gut")]
        case .heart: [("Ruhepuls", "54 bpm"), ("Gehpuls", "96 bpm"), ("Herzfrequenz beim Gehen", "104 bpm"), ("Letzte HRV-Messung", "58 ms"), ("Blutsauerstoff", "98 %")]
        case .activity: [("Gehstrecke", "6,2 km"), ("Aktive Energie", "438 kcal"), ("Trainingsminuten", "42 Min."), ("Stehstunden", "11 Std."), ("Treppen", "8 Stockwerke")]
        case .mindfulness: [("Sitzungen", "2"), ("Längste Sitzung", "10 Min."), ("Diese Woche", "96 Min."), ("Atemübungen", "1")]
        case .body: [("Größe", "172 cm"), ("Körperfett", "22,1 %"), ("Letzte Erfassung", "Heute, 07:10"), ("Trend", "Stabil")]
        }
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    summaryCard
                    chartCard
                    detailRows
                    explanation
                    Text("Beispieldaten · nicht aus Apple Health gelesen")
                        .font(.system(size: 10))
                        .foregroundStyle(.primary.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 30)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Einstellungen")
            }
        }
        .navigationDestination(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 7) {
                Image(systemName: category.symbol)
                    .foregroundStyle(category.color)
                Text(measureLabel)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.primary.opacity(0.5))
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(value)
                    .font(.system(size: 34, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .tracking(-0.8)
                    .foregroundStyle(.primary)
                Spacer()
                Text("Persönlicher Verlauf")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(category.color)
            }
            Text(periodDescription)
                .font(.system(size: 12))
                .foregroundStyle(.primary.opacity(0.45))
        }
        .padding(19)
        .frame(maxWidth: .infinity, alignment: .leading)
        .healthPanel(cornerRadius: 21)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                Text("VERLAUF")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.primary.opacity(0.48))
                Spacer()
                Text(selectedRange.uppercased())
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .tracking(0.7)
                    .foregroundStyle(.primary.opacity(0.36))
            }
            DetailTrendChart(category: category, range: selectedRange)
                .frame(height: 120)
            HStack {
                ForEach(chartLabels, id: \.self) { label in
                    Text(label)
                    if label != chartLabels.last { Spacer() }
                }
            }
            .font(.system(size: 8, weight: .medium, design: .rounded))
            .tracking(0.6)
            .foregroundStyle(.primary.opacity(0.32))
        }
        .padding(19)
        .healthPanel(cornerRadius: 21)
    }

    private var chartLabels: [String] {
        switch selectedRange {
        case "Tag": ["06", "09", "12", "15", "18", "21", "24"]
        case "Monat": ["1.", "5.", "10.", "15.", "20.", "25.", "30."]
        case "6 Mon.": ["MAI", "JUN", "JUL", "AUG", "SEP", "OKT", "NOV"]
        default: ["MO", "DI", "MI", "DO", "FR", "SA", "SO"]
        }
    }

    private var detailRows: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WEITERE MESSWERTE")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(.primary.opacity(0.46))
            VStack(spacing: 0) {
                ForEach(Array(secondaryMetrics.enumerated()), id: \.offset) { index, metric in
                    HStack {
                        Text(metric.0)
                            .font(.system(size: 13))
                            .foregroundStyle(.primary.opacity(0.72))
                        Spacer()
                        Text(metric.1)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.primary.opacity(0.92))
                    }
                    .padding(.vertical, 14)
                    if index < secondaryMetrics.count - 1 {
                        Rectangle().fill(.primary.opacity(0.09)).frame(height: 0.6)
                    }
                }
            }
            .padding(.horizontal, 16)
            .healthPanel(cornerRadius: 19)
        }
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("DIESE MESSUNG")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .tracking(1)
                .foregroundStyle(.primary.opacity(0.42))
            Text(description)
                .font(.system(size: 13))
                .foregroundStyle(.primary.opacity(0.62))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(category.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct DetailTrendChart: View {
    let category: HealthCategory
    let range: String

    private var values: [CGFloat] {
        let samples: [CGFloat] = switch category {
        case .sleep: [0.45, 0.7, 0.61, 0.83, 0.65, 0.9, 0.74, 0.78, 0.54, 0.86, 0.68, 0.92, 0.7, 0.82, 0.6, 0.78, 0.9]
        case .heart: [0.41, 0.55, 0.48, 0.68, 0.57, 0.75, 0.63, 0.8, 0.67, 0.87, 0.72, 0.81, 0.65, 0.76, 0.88, 0.69, 0.79]
        case .activity: [0.3, 0.62, 0.47, 0.82, 0.59, 0.91, 0.73, 0.55, 0.78, 0.96, 0.69, 0.85, 0.51, 0.73, 0.88, 0.64, 0.8]
        case .mindfulness: [0.25, 0.5, 0.3, 0.65, 0.42, 0.72, 0.55, 0.4, 0.8, 0.62, 0.35, 0.7, 0.52, 0.85, 0.45, 0.68, 0.78]
        case .body: [0.67, 0.68, 0.66, 0.69, 0.68, 0.7, 0.69, 0.67, 0.68, 0.71, 0.69, 0.68, 0.7, 0.69, 0.68, 0.7, 0.69]
        }
        let adjustment: CGFloat = switch range {
        case "Tag": 0.06
        case "Monat": -0.03
        case "6 Mon.": -0.06
        default: 0
        }
        return samples.map { min(max($0 + adjustment, 0.1), 0.96) }
    }

    var body: some View {
        Chart {
            RuleMark(y: .value("Referenz", 0.5))
                .foregroundStyle(.primary.opacity(0.12))
            ForEach(values.indices, id: \.self) { index in
                LineMark(
                    x: .value("Messpunkt", index),
                    y: .value("Wert", Double(values[index]))
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(category.color)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...1)
        .accessibilityLabel("\(category.rawValue), \(range)")
    }
}
