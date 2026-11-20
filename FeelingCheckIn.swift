import SwiftUI

struct FeelingCheckIn: View {
    @Binding var selectedFeeling: Int

    private let feelings: [(String, String)] = [
        ("sun.max", "Leicht"),
        ("circle.lefthalf.filled", "Okay"),
        ("minus", "Neutral"),
        ("cloud", "Müde"),
        ("moon", "Erschöpft")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                Text("Wie fühlst du dich?")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.92))
                Spacer()
                Text("Dein Gefühl zählt.")
                    .font(.system(size: 11))
                    .foregroundStyle(.primary.opacity(0.4))
            }
            HStack(spacing: 0) {
                ForEach(feelings.indices, id: \.self) { index in
                    Button {
                        withAnimation(.snappy(duration: 0.25)) { selectedFeeling = index }
                    } label: {
                        VStack(spacing: 9) {
                            Image(systemName: feelings[index].0)
                                .font(.system(size: 18))
                                .frame(height: 22)
                            Text(feelings[index].1)
                                .font(.system(size: 10, weight: selectedFeeling == index ? .medium : .regular))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(.primary)
                        .opacity(selectedFeeling == index ? 1 : 0.42)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if selectedFeeling == index {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.regularMaterial)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .healthCard()
    }
}
