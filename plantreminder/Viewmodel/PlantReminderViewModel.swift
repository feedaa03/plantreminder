import SwiftUI
import Combine

final class PlantReminderViewModel: ObservableObject {
    private let notificationScheduler: NotificationScheduling

    init(notificationScheduler: NotificationScheduling = NotificationManager()) {
        self.notificationScheduler = notificationScheduler
    }

    // Inputs bound from the UI
    @Published var plantName: String = ""
    @Published var selectedRoom: String = "Bedroom"
    @Published var selectedLight: String = "Full Sun"
    @Published var selectedWaterDays: String = "Every Day"
    @Published var selectedWaterAmount: String = "20–50 ml"

    // Save into PlantStore
    func save(to store: PlantStore, completion: (() -> Void)? = nil) {
        let trimmed = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newItem = CheckboxItem(
            name: trimmed,
            location: "in \(selectedRoom)",
            isChecked: false,
            sunlight: selectedLight,
            waterAmount: selectedWaterAmount
        )
        store.items.append(newItem)
        // Schedule a water reminder in 10 seconds via the injected scheduler
        notificationScheduler.scheduleWaterReminder(in: 10)
        completion?()
    }
}
