import Charts
import SwiftUI

enum HealthCategory: String, CaseIterable, Identifiable {
    case sleep = "Schlaf"
    case heart = "Herz"
    case activity = "Aktivität"
    case mindfulness = "Achtsamkeit"
    case body = "Körper"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .sleep: "bed.double.fill"
        case .heart: "heart.fill"
        case .activity: "figure.walk"
        case .mindfulness: "brain.head.profile"
        case .body: "scalemass.fill"
        }
    }
    var color: Color {
        switch self {
        case .sleep: .indigo
        case .heart: .red
        case .activity: .green
        case .mindfulness: .cyan
        case .body: .orange
        }
    }
}

struct DataOverviewView: View {
    @State private var selectedRange = "Woche"
    @State private var selectedCategory: HealthCategory?
    @State private var isShowingSettings = false
    private let ranges = ["Tag", "Woche", "Monat", "6 Mon."]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 27) {
                        header
                        rangePicker
                        favoritesSection
                        categorySection
                        insight
                        PrivacyFooter()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 34)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
            }
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedCategory) { category in
                HealthCategoryDetailView(category: category, selectedRange: selectedRange)
            }
            .navigationDestination(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
        .tint(.accentColor)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("GESUNDHEIT")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(1.25)
                    .foregroundStyle(.primary.opacity(0.52))
                Spacer()
            }
            Text("Daten")
                .font(.system(size: 34, weight: .bold))
                .tracking(-0.7)
                .foregroundStyle(.primary)
            Text("Deine Gesundheit im Überblick.")
                .font(.system(size: 15))
                .foregroundStyle(.primary.opacity(0.53))
        }
    }

    private var rangePicker: some View {
        Picker("Zeitraum", selection: $selectedRange) {
            ForEach(ranges, id: \.self) { range in
                Text(range).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle("Favoriten", trailing: nil)
            VStack(spacing: 0) {
                Button { selectedCategory = .sleep } label: {
                    FavoriteDataRow(category: .sleep, value: sleepAverage, unit: "Std.", detail: selectedRange == "Tag" ? "Schlafdauer · letzte Nacht" : "Schlafdauer · Ø pro Nacht", chart: trend(for: .sleep))
                }
                .buttonStyle(.plain)
                rowDivider
                Button { selectedCategory = .heart } label: {
                    FavoriteDataRow(category: .heart, value: heartAverage, unit: "ms", detail: "Herzfrequenzvariabilität · Ø", chart: trend(for: .heart))
                }
                .buttonStyle(.plain)
                rowDivider
                Button { selectedCategory = .activity } label: {
                    FavoriteDataRow(category: .activity, value: stepsAverage, unit: "Schritte", detail: "Pro Tag · Ø", chart: trend(for: .activity))
                }
                .buttonStyle(.plain)
            }
            .healthPanel(cornerRadius: 20)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle("Kategorien", trailing: nil)
            VStack(spacing: 0) {
                ForEach(Array(HealthCategory.allCases.enumerated()), id: \.element.id) { index, category in
                    Button { selectedCategory = category } label: {
                        HStack(spacing: 13) {
                            Image(systemName: category.symbol)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(category.color)
                                .frame(width: 25)
                            Text(category.rawValue)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(.primary.opacity(0.92))
                            Spacer()
                            Text(categorySummary(category))
                                .font(.system(size: 12))
                                .foregroundStyle(.primary.opacity(0.48))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.primary.opacity(0.28))
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if index < HealthCategory.allCases.count - 1 {
                        rowDivider.padding(.leading, 53)
                    }
                }
            }
            .healthPanel(cornerRadius: 20)
        }
    }

    private var insight: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.indigo)
                .frame(width: 30, height: 30)
                .background(Circle().fill(.indigo.opacity(0.16)))
            VStack(alignment: .leading, spacing: 5) {
                Text("Dein Wochenrückblick")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Deine Schlafdauer liegt nah an deinem persönlichen Durchschnitt. Deine HRV blieb im gewohnten Bereich.")
                    .font(.system(size: 12))
                    .foregroundStyle(.primary.opacity(0.58))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .healthPanel(cornerRadius: 20)
    }

    private var rowDivider: some View {
        Rectangle().fill(.primary.opacity(0.1)).frame(height: 0.6)
    }

    private var sleepAverage: String {
        switch selectedRange {
        case "Tag": "7,7"
        case "Monat": "7,5"
        case "6 Mon.": "7,4"
        default: "7,6"
        }
    }

    private var heartAverage: String {
        switch selectedRange {
        case "Tag": "58"
        case "Monat": "54"
        case "6 Mon.": "55"
        default: "56"
        }
    }

    private var stepsAverage: String {
        switch selectedRange {
        case "Tag": "10.230"
        case "Monat": "8.100"
        case "6 Mon.": "7.950"
        default: "8.420"
        }
    }

    private func trend(for category: HealthCategory) -> [CGFloat] {
        let offset: CGFloat = switch selectedRange {
        case "Tag": 0.1
        case "Monat": -0.04
        case "6 Mon.": -0.08
        default: 0
        }
        let values: [CGFloat] = switch category {
        case .sleep: [0.53, 0.76, 0.65, 0.91, 0.68, 0.82, 0.72]
        case .heart: [0.4, 0.55, 0.47, 0.71, 0.58, 0.8, 0.67]
        case .activity: [0.54, 0.78, 0.64, 0.9, 0.72, 0.84, 0.62]
        case .mindfulness: [0.35, 0.5, 0.68, 0.42, 0.75, 0.55, 0.82]
        case .body: [0.65, 0.67, 0.66, 0.68, 0.67, 0.69, 0.68]
        }
        return values.map { min(max($0 + offset, 0.12), 0.96) }
    }


    private func sectionTitle(_ title: String, trailing: String?) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.primary)
            Spacer()
            if let trailing {
                Button(trailing) { }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.indigo)
            }
        }
    }

    private func categorySummary(_ category: HealthCategory) -> String {
        switch category {
        case .sleep: "\(sleepAverage) Std."
        case .heart: "\(heartAverage) ms · 54 bpm"
        case .activity: "\(stepsAverage) Schritte"
        case .mindfulness: "18 Min."
        case .body: "Heute erfasst"
        }
    }
}

private struct FavoriteDataRow: View {
    let category: HealthCategory
    let value: String
    let unit: String
    let detail: String
    let chart: [CGFloat]

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(category.color)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(value)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    Text(unit)
                        .font(.system(size: 11))
                        .foregroundStyle(.primary.opacity(0.55))
                }
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(.primary.opacity(0.42))
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            MiniTrend(values: chart, color: category.color)
                .frame(width: 62, height: 30)
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.25))
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

private struct MiniTrend: View {
    let values: [CGFloat]
    let color: Color

    var body: some View {
        Chart {
            ForEach(values.indices, id: \.self) { index in
                LineMark(
                    x: .value("Messpunkt", index),
                    y: .value("Wert", Double(values[index]))
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(color)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...1)
        .accessibilityLabel("Messwertverlauf")
    }
}

extension HealthCategory: Hashable { }
