//
//  NotificationManager.swift
//  plantreminder
//
//  Created by Feda  on 28/10/2025.
//


import Foundation
import UserNotifications

struct NotificationManager {
    static func scheduleWaterReminder(in seconds: TimeInterval = 10) {
        let center = UNUserNotificationCenter.current()
        // Request authorization first (idempotent; system will only prompt once)
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    guard granted else { return }
                    schedule(seconds: seconds)
                }
            } else if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                schedule(seconds: seconds)
            } else {
                // Not authorized; do nothing
            }
        }

        func schedule(seconds: TimeInterval) {
            let content = UNMutableNotificationContent()
            content.title = "Plant Reminder"
            content.body = "Hey! let's water your plant"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
            let request = UNNotificationRequest(identifier: "water_reminder_" + UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}
