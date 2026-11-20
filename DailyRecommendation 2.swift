import SwiftUI

struct DailyRecommendation: View {
    let selectedFeeling: Int

    @State private var isGenerating = true
    @State private var hasAppeared = false
    @State private var lightIsMoving = false
    @State private var visibleCharacters = 0
    @State private var generationTask: Task<Void, Never>?

    private let accent = Color(red: 0.55, green: 0.63, blue: 1.0)

    private var title: String {
        switch selectedFeeling {
        case 0: "Nutze deine Energie."
        case 1: "Bleib in deinem Rhythmus."
        case 3: "Geh es heute ruhig an."
        case 4: "Gönn dir echte Erholung."
        default: "Ein guter Tag für Bewegung."
        }
    }

    private var bodyText: String {
        switch selectedFeeling {
        case 0: "Dein Schlaf war solide und du fühlst dich leicht. Eine aktive Einheit passt heute gut."
        case 1: "Deine Erholung liegt im persönlichen Bereich. Eine ausgewogene Mischung aus Aktivität und Pausen passt gut."
        case 3: "Deine Nacht war ordentlich, dein Gefühl braucht etwas mehr Raum. Sanfte Bewegung reicht heute aus."
        case 4: "Hör auf deinen Körper. Halte den Tag leicht und setze Erholung an erste Stelle."
        default: "Schlaf und Erholung sind stabil. Ein Spaziergang oder lockere Bewegung kann dir heute guttun."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(accent.opacity(isGenerating ? 0.18 : 0.12))
                            .frame(width: 26, height: 26)
                        Image(systemName: isGenerating ? "sparkles" : "checkmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(accent)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    Text(isGenerating ? "APPLE INTELLIGENCE" : "DEIN IMPULS")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(1.25)
                        .foregroundStyle(isGenerating ? accent.opacity(0.95) : .primary.opacity(0.48))
                        .contentTransition(.numericText())
                }
                Spacer()
                if isGenerating {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(accent.opacity(0.85))
                        .transition(.opacity)
                }
            }

            if isGenerating {
                generationStatus
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            VStack(alignment: .leading, spacing: 9) {
                Text(isGenerating ? "Ich stimme deinen Tag ab …" : title)
                    .font(.system(size: 21, weight: .regular, design: .rounded))
                    .tracking(-0.3)
                    .foregroundStyle(.primary.opacity(0.94))
                    .contentTransition(.opacity)
                    .id("title-\(isGenerating)-\(selectedFeeling)")

                if !isGenerating {
                    Text(String(bodyText.prefix(visibleCharacters)))
                        .font(.system(size: 13))
                        .foregroundStyle(.primary.opacity(0.56))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(.primary.opacity(0.09))
                .frame(height: 0.7)

            HStack(spacing: 7) {
                Image(systemName: isGenerating ? "waveform.path" : "arrow.up.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isGenerating ? accent.opacity(0.85) : .primary.opacity(0.48))
                Text(isGenerating ? "Gefühl · Schlaf · Erholung" : "Auf Gefühl und Schlaf abgestimmt")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.primary.opacity(isGenerating ? 0.56 : 0.48))
                    .contentTransition(.opacity)
            }
        }
        .healthCard()
        .onAppear {
            hasAppeared = true
            startGeneration()
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                lightIsMoving = true
            }
        }
        .onChange(of: selectedFeeling) { _, _ in
            guard hasAppeared else { return }
            startGeneration()
        }
        .onDisappear {
            generationTask?.cancel()
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.86), value: isGenerating)
    }

    private var generationStatus: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(.primary.opacity(0.07))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [accent.opacity(0.22), accent, Color.cyan.opacity(0.75), accent.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * 0.38)
                    .blur(radius: 1.5)
                    .offset(x: lightIsMoving ? geometry.size.width * 0.62 : 0)
            }
        }
        .frame(height: 2)
        .clipShape(Capsule())
        .accessibilityLabel("Empfehlung wird erstellt")
    }

    private func startGeneration() {
        generationTask?.cancel()
        visibleCharacters = 0
        withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
            isGenerating = true
        }

        generationTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1450))
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.84)) {
                isGenerating = false
            }
            for character in 1...bodyText.count {
                guard !Task.isCancelled else { return }
                visibleCharacters = character
                try? await Task.sleep(for: .milliseconds(13))
            }
        }
    }
}
