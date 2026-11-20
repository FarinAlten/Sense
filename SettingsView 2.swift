import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    @AppStorage("healthy.appearance") private var appearance = "dark"
    @AppStorage("healthy.reminderEnabled") private var reminderEnabled = false

    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? .now
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var canOpenAppSettings = false

    var body: some View {
        Form {
            Section("Darstellung") {
                Picker("Erscheinungsbild", selection: $appearance) {
                    Text("System").tag("system")
                    Text("Hell").tag("hell")
                    Text("Dunkel").tag("dark")
                }
            }

            Section {
                Toggle("Tägliche Erinnerung", isOn: reminderBinding)
                if reminderEnabled {
                    DatePicker(
                        "Uhrzeit",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            } header: {
                Text("Check-in")
            } footer: {
                Text("Ein kurzer Moment für deinen täglichen Check-in. Du kannst die Erinnerung jederzeit hier ausschalten.")
            }

            Section {
                LabeledContent {
                    Text("Nicht verbunden")
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Apple Health", systemImage: "heart.text.square")
                }
                LabeledContent("Dashboard", value: "Beispieldaten")
            } header: {
                Text("Datenquellen")
            } footer: {
                Text("HealthKit ist in dieser Vorschau noch nicht angebunden. Die angezeigten Gesundheitswerte sind Beispiele.")
            }

            Section("Datenschutz") {
                Label("Keine persönlichen Gesundheitsdaten geladen", systemImage: "lock.shield")
                    .font(.body)
                Text("Die Vorschau liest keine Gesundheitsdaten aus Apple Health.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                LabeledContent("Version", value: "1.0")
            }
        }
        .navigationTitle("Einstellungen")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear(perform: restoreReminderTime)
        .onChange(of: reminderTime) { _, newTime in
            UserDefaults.standard.set(newTime, forKey: "healthy.reminderTime")
            if reminderEnabled {
                scheduleReminder()
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            if canOpenAppSettings {
                Button("Später", role: .cancel) { }
                Button("Einstellungen öffnen") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
            } else {
                Button("OK", role: .cancel) { }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private var reminderBinding: Binding<Bool> {
        Binding(
            get: { reminderEnabled },
            set: { setReminderEnabled($0) }
        )
    }

    private func setReminderEnabled(_ enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        if !enabled {
            reminderEnabled = false
            center.removePendingNotificationRequests(withIdentifiers: ["daily-check-in"])
            center.removeDeliveredNotifications(withIdentifiers: ["daily-check-in"])
            return
        }

        Task { @MainActor in
            do {
                let settings = await center.notificationSettings()
                let authorized: Bool
                if settings.authorizationStatus == .notDetermined {
                    authorized = try await center.requestAuthorization(options: [.alert, .sound])
                } else {
                    authorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                }

                guard authorized else {
                    reminderEnabled = false
                    presentAlert(
                        title: "Mitteilungen erlauben",
                        message: "Aktiviere Mitteilungen für healthy in den iOS-Einstellungen, damit deine Check-in-Erinnerung erscheinen kann.",
                        canOpenSettings: true
                    )
                    return
                }

                reminderEnabled = true
                scheduleReminder()
            } catch {
                reminderEnabled = false
                presentAlert(title: "Erinnerung nicht eingerichtet", message: "Bitte versuche es später erneut.")
            }
        }
    }

    private func restoreReminderTime() {
        if let savedTime = UserDefaults.standard.object(forKey: "healthy.reminderTime") as? Date {
            reminderTime = savedTime
        }
    }

    private func scheduleReminder() {
        var components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        components.calendar = .current

        let content = UNMutableNotificationContent()
        content.title = "Zeit für deinen Check-in"
        content.body = "Nimm dir einen Moment und halte fest, wie du dich heute fühlst."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-check-in", content: content, trigger: trigger)

        Task { @MainActor in
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                reminderEnabled = false
                presentAlert(title: "Erinnerung nicht eingerichtet", message: "Bitte versuche es später erneut.")
            }
        }
    }

    private func presentAlert(title: String, message: String, canOpenSettings: Bool = false) {
        alertTitle = title
        alertMessage = message
        canOpenAppSettings = canOpenSettings
        showingAlert = true
    }
}
