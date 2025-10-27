import SwiftUI

@main
struct PlantreminderApp: App {
    @StateObject private var store = PlantStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
