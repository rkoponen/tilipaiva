import Foundation
import Observation
import os
import UserNotifications

/// Schedules the app's one notification — a reminder on the morning of a payment
/// day — and owns the permission for it.
///
/// The rules live in `PaydayReminderSchedule`; this is the part that talks to
/// the system, so it stays thin. The dates it holds are absolute: the app has to
/// be opened again for the window to slide, which is exactly why every return to
/// the foreground reschedules.
@MainActor
@Observable
final class PaydayNotifications {
    /// Whether the user wants a reminder. Mirrors the stored preference, so the
    /// settings switch can read it back after the permission has been asked.
    private(set) var isEnabled: Bool

    /// Whether the system has the permission turned off, so the settings screen
    /// can point at the Settings app instead of offering a switch it cannot keep.
    private(set) var isDenied = false

    private let center: UNUserNotificationCenter
    private let store: PaymentSourceStore
    private let preferences: PaydayReminderPreferences
    private let schedule: PaydayReminderSchedule

    init(
        center: UNUserNotificationCenter = .current(),
        store: PaymentSourceStore = PaymentSourceStore(),
        preferences: PaydayReminderPreferences = PaydayReminderPreferences(),
        schedule: PaydayReminderSchedule = PaydayReminderSchedule()
    ) {
        self.center = center
        self.store = store
        self.preferences = preferences
        self.schedule = schedule
        self.isEnabled = preferences.isEnabled
    }

    /// Reads the permission and the stored preference, e.g. when the settings
    /// screen appears or the app comes back to the foreground.
    func refresh() async {
        let status = await center.notificationSettings().authorizationStatus
        isDenied = status == .denied
        isEnabled = preferences.isEnabled
    }

    /// Turns the reminder on or off.
    ///
    /// Asking for the permission happens here, so the switch never says yes on
    /// its own: a refused ask leaves it off and points at Settings instead.
    func setEnabled(_ enabled: Bool) async {
        guard enabled else {
            preferences.setEnabled(false)
            isEnabled = false
            await clearPending()
            return
        }

        guard await requestAuthorization() else {
            isDenied = true
            isEnabled = false
            return
        }

        preferences.setEnabled(true)
        isEnabled = true
        isDenied = false
        await reschedule()
    }

    /// Schedules the reminders the sources call for, soonest first.
    ///
    /// The first call asks for the permission: a reminder only makes sense once
    /// there is a payment to remind about, so the prompt arrives with the user's
    /// own first source rather than at launch. Later calls just slide the window
    /// as the days pass.
    func reschedule() async {
        let sources = store.load()
        guard !sources.isEmpty else {
            await clearPending()
            return
        }

        let status = await center.notificationSettings().authorizationStatus
        isDenied = status == .denied

        if status == .notDetermined {
            guard await requestAuthorization() else {
                isDenied = true
                return
            }
            preferences.setEnabled(true)
            isEnabled = true
        } else if status == .denied {
            await clearPending()
            return
        }

        guard isEnabled else { return }
        await replacePending(with: schedule.reminders(for: sources, onOrAfter: .now))
    }

    // MARK: - Private helpers

    /// Whether the system lets the app send its notification.
    private func requestAuthorization() async -> Bool {
        ((try? await center.requestAuthorization(options: [.alert, .sound])) ?? false)
    }

    /// Takes the app's pending requests away, leaving anything else the system
    /// holds for it alone.
    private func clearPending() async {
        let pending = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(PaydayReminderSchedule.identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: pending)
    }

    /// Replaces the app's pending requests with the given reminders.
    private func replacePending(with reminders: [PaydayReminder]) async {
        await clearPending()

        for reminder in reminders {
            do {
                try await center.add(request(for: reminder))
            } catch {
                Self.logger.error("Failed to schedule \(reminder.id): \(error.localizedDescription)")
            }
        }
    }

    private func request(for reminder: PaydayReminder) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Payday!")
        content.body = reminder.message
        content.sound = .default

        // The Finnish morning, carried as components in the Finnish time zone so
        // the reminder follows the payment day rather than the device's. Should
        // the system read them as local instead, they still land at nine in the
        // morning of the payment day.
        var components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: schedule.moment(for: reminder.day)
        )
        components.timeZone = BankingCalendar.timeZone

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
    }

    private static let logger = Logger(subsystem: "fi.ruupert.Tilipaiva", category: "PaydayNotifications")
}
