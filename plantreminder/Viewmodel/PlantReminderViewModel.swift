//
//  PlantReminderViewModel.swift
//  plantreminder
//
//  Created by Feda  on 28/10/2025.
//


import Foundation
import Combine

final class PlantReminderViewModel: ObservableObject {
    @Published var plantName: String = ""
    @Published var selectedRoom: String = "Bedroom"
    @Published var selectedLight: String = "Full Sun"
    @Published var selectedWaterDays: String = "Every Day"
    @Published var selectedWaterAmount: String = "20–50 ml"

    func reset() {
        plantName = ""
        selectedRoom = "Bedroom"
        selectedLight = "Full Sun"
        selectedWaterDays = "Every Day"
        selectedWaterAmount = "20–50 ml"
    }

    func save(to store: PlantStore, onSaved: () -> Void) {
        let name = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let newItem = CheckboxItem(
            name: name,
            location: "in \(selectedRoom)",
            isChecked: false,
            sunlight: selectedLight,
            waterAmount: selectedWaterAmount
        )
        store.items.append(newItem)
        NotificationManager.scheduleWaterReminder(in: 10)
        onSaved()
        reset()
    }
}
