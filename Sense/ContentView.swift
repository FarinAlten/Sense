import SwiftUI

struct ContentView: View {
    @State private var selectedFeeling = 2
    @State private var selectedTab = AppTab.today
    @State private var isShowingSettings = false
    @AppStorage("healthy.appearance") private var appearance = "dark"

    var body: some View {
        TabView(selection: $selectedTab) {
            todayView
                .tabItem { Label("Heute", systemImage: "sun.max") }
                .tag(AppTab.today)

            DataOverviewView()
                .tabItem { Label("Daten", systemImage: "chart.xyaxis.line") }
                .tag(AppTab.data)
        }
        .tint(.accentColor)
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "hell": .light
        case "system": nil
        default: .dark
        }
    }

    private var todayView: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        DashboardHeader()
                        FeelingCheckIn(selectedFeeling: $selectedFeeling)
                        HealthMetricsSection()
                        DailyRecommendation(selectedFeeling: selectedFeeling)
                        PrivacyFooter()
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationDestination(isPresented: $isShowingSettings) {
                SettingsView()
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
        }
    }
}

enum AppTab: Hashable {
    case today
    case data
}

#Preview {
    ContentView()
}
