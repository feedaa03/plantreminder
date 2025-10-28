import SwiftUI
import Combine
import Foundation

// MARK: - Model
struct CheckboxItem: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var location: String
    var isChecked: Bool
    var sunlight: String = "Full sun"
    var waterAmount: String = "20–50 ml"
}

// MARK: - Plant Store
final class PlantStore: ObservableObject {
    @Published var items: [CheckboxItem]
    init(items: [CheckboxItem] = []) { // بدون أمثلة جاهزة
        self.items = items
    }
}

// MARK: - Main App
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

// MARK: - Main List View
struct TodayReminderList: View {
    @EnvironmentObject private var store: PlantStore
    @State private var showAddPlantSheet = false
    @State private var showAllDone = false
    @State private var showEditSheet = false
    @State private var selectedItemID: UUID? = nil
    private var isAllDone: Bool { !store.items.isEmpty && store.items.allSatisfy { $0.isChecked } }
    
    private var countsOfcheck: Double {
        guard !store.items.isEmpty else { return 0 }
        let checked = store.items.filter { $0.isChecked }.count
        return (Double(checked) / Double(store.items.count)) * 100.0
    }
    
    private var plantsStatusText: String {
        let total = store.items.count
        let checked = store.items.filter { $0.isChecked }.count

        // When there are no plants or none are checked
        if total == 0 || checked == 0 {
            return "Your plants are waiting for a sip 💦"
        }

        // Single plant checked
        if checked == 1 {
            return "1 of your plants feels loved today ✨"
        }

        // All plants checked
        if checked == total {
            return "All your plants are happy today 🌸"
        }

        // Some plants checked
        return "\(checked) of your plants feel loved today ✨"
    }
    
    private var selectedItemBinding: Binding<CheckboxItem>? {
        guard let id = selectedItemID, let index = store.items.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return $store.items[index]
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Plants 🌱")
                .foregroundColor(.white)
                .font(.largeTitle.bold())
                .padding(.top)

            Divider()
                .background(Color.white.opacity(0.3))
        }
    }

    @ViewBuilder
    private var statusAndProgressSection: some View {
        VStack {
            Text(plantsStatusText)
                .foregroundColor(.white.opacity(0.85))
                .font(.headline)
                .padding(.bottom, 8)
                .animation(.easeInOut(duration: 0.3), value: plantsStatusText)

            ProgressView(value: countsOfcheck, total: 100)
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .frame(width: 361)
                .tint(.accentColor)
        }
    }

    @ViewBuilder
    private var plantsListSection: some View {
        List {
            ForEach($store.items) { $item in
                VStack(spacing: 0) {
                    TodayReminder(item: $item, onRowTap: {
                        selectedItemID = item.id
                        showEditSheet = true
                    }, onToggle: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            store.items.sort { (lhs, rhs) in
                                (lhs.isChecked ? 1 : 0) < (rhs.isChecked ? 1 : 0)
                            }
                        }
                    })
                        .padding(.vertical, 22)
                        .listRowBackground(Color.black)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if let index = store.items.firstIndex(where: { $0.id == item.id }) {
                                    store.items.remove(at: index)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }

                    // Custom separator
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.black)
                }
                .listRowBackground(Color.black)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.black)
    }//
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                headerSection

                statusAndProgressSection

                plantsListSection
            }
            .padding(.horizontal)

            // زر الإضافة (+)
            Button(action: { showAddPlantSheet.toggle() }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(color: Color.white.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
            .sheet(isPresented: $showAddPlantSheet) {
                AddPlantReminderView()
                    .environmentObject(store)
                    .preferredColorScheme(.dark)
                    .presentationDetents([.large])
            }
            .sheet(isPresented: $showEditSheet, onDismiss: { selectedItemID = nil }) {
                if let selectedBinding = selectedItemBinding {
                    EditReminderSheetView(item: selectedBinding, onDelete: {
                        if let id = selectedItemID,
                           let index = store.items.firstIndex(where: { $0.id == id }) {
                            store.items.remove(at: index)
                        }
                        selectedItemID = nil
                    })
                    .environmentObject(store)
                    .preferredColorScheme(.dark)
                    .presentationDetents([.large])
                }
            }
        }
        .onChange(of: store.items) { oldValue, newValue in
            let oldAllDone = !oldValue.isEmpty && oldValue.allSatisfy { $0.isChecked }
            let newAllDone = !newValue.isEmpty && newValue.allSatisfy { $0.isChecked }
            if newAllDone && !oldAllDone {
                showAllDone = true
            }
        }
        .fullScreenCover(isPresented: $showAllDone, onDismiss: { showAllDone = false }) {
            AllDoneView()
        }
    }
}

// MARK: - Single Row
struct TodayReminder: View {
    @Binding var item: CheckboxItem
    var onRowTap: (() -> Void)? = nil
    var onToggle: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "location")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 12))
                Text(item.location)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 13))
            }
            .opacity(item.isChecked ? 0.6 : 1.0)
            
            HStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { item.isChecked.toggle() }
                    onToggle?()
                } label: {
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isChecked ? .accentColor : .gray)
                        .font(.system(size: 22))
                }
                .buttonStyle(.plain)
                
                Text(item.name)
                    .strikethrough(item.isChecked, pattern: .solid, color: .white.opacity(0.8))
                    .foregroundStyle(.white.opacity(item.isChecked ? 0.6 : 1.0))
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeInOut(duration: 0.2), value: item.isChecked)
            }
            
            HStack(spacing: 12) {
                Label { Text(item.sunlight).font(.caption).foregroundColor(.yellow) }
                      icon: { Image(systemName: "sun.max.fill").foregroundColor(.yellow) }
                      .padding(.horizontal, 8)
                      .padding(.vertical, 4)
                      .background(Color.yellow.opacity(0.15))
                      .cornerRadius(8)
                
                Label { Text(item.waterAmount).font(.caption).foregroundColor(.blue) }
                      icon: { Image(systemName: "drop.fill").foregroundColor(.blue) }
                      .padding(.horizontal, 8)
                      .padding(.vertical, 4)
                      .background(Color.blue.opacity(0.15))
                      .cornerRadius(8)
            }
            .padding(.leading, 34)
            .opacity(item.isChecked ? 0.6 : 1.0)
        }
        .contentShape(Rectangle())
        .onTapGesture { onRowTap?() }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Plant Reminder Sheet
private struct AddPlantReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: PlantStore
    
    @State private var plantName: String = ""
    @State private var selectedRoom = "Bedroom"
    @State private var selectedLight = "Full Sun"
    @State private var selectedWaterDays = "Every Day"
    @State private var selectedWaterAmount = "20–50 ml"
    @State private var activePicker: PickerType?
    
    enum PickerType { case room, light, waterDays, waterAmount }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color("BackGroundColor").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Top Bar
                    HStack {
                        LiquidGlassCircleButton(systemName: "xmark", action: { dismiss() })
                        Spacer()
                        Text("Set Reminder")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        LiquidGlassCircleButton(systemName: "checkmark", tint: Color("AccentColor"), action: {
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
                            dismiss()
                        })
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer().frame(height: 60)
                    
                    GlassTextField(text: $plantName, title: "Plant Name", placeholder: "", icon: nil)
                    
                    GlassGroup {
                        GlassRow(title: "Room", value: selectedRoom, icon: "location", showDivider: true)
                            .onTapGesture { activePicker = .room }
                        GlassRow(title: "Light", value: selectedLight, icon: "sun.max.fill")
                            .onTapGesture { activePicker = .light }
                    }
                    
                    GlassGroup {
                        GlassRow(title: "Watering Days", value: selectedWaterDays, icon: "drop.fill", showDivider: true)
                            .onTapGesture { activePicker = .waterDays }
                        GlassRow(title: "Water", value: selectedWaterAmount, icon: "drop.fill")
                            .onTapGesture { activePicker = .waterAmount }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 30)
                .confirmationDialog("Select an option", isPresented: .constant(activePicker != nil), titleVisibility: .visible) {
                    if activePicker == .room {
                        Button("Bedroom") { selectedRoom = "Bedroom"; activePicker = nil }
                        Button("Living Room") { selectedRoom = "Living Room"; activePicker = nil }
                        Button("Balcony") { selectedRoom = "Balcony"; activePicker = nil }
                        Button("Kitchen") { selectedRoom = "Kitchen"; activePicker = nil }
                        Button("Bathroom") { selectedRoom = "Bathroom"; activePicker = nil }
                    }
                    if activePicker == .light {
                        Button("Full Sun") { selectedLight = "Full Sun"; activePicker = nil }
                        Button("Partial Shade") { selectedLight = "Partial Shade"; activePicker = nil }
                        Button("Low Light") { selectedLight = "Low Light"; activePicker = nil }
                    }
                    if activePicker == .waterDays {
                        Button("Every Day") { selectedWaterDays = "Every Day"; activePicker = nil }
                        Button("Every 2 Days") { selectedWaterDays = "Every 2 Days"; activePicker = nil }
                        Button("Every 3 Days") { selectedWaterDays = "Every 3 Days"; activePicker = nil }
                        Button("Once a week") { selectedWaterDays = "Once a week"; activePicker = nil }
                        Button("Every 10 Days") { selectedWaterDays = "Every 10 Days"; activePicker = nil }
                        Button("Every 2 weeks") { selectedWaterDays = "Every 2 weeks"; activePicker = nil }
                    }
                    if activePicker == .waterAmount {
                        Button("20–50 ml") { selectedWaterAmount = "20–50 ml"; activePicker = nil }
                        Button("50–100 ml") { selectedWaterAmount = "50–100 ml"; activePicker = nil }
                        Button("100–200 ml") { selectedWaterAmount = "100–200 ml"; activePicker = nil }
                        Button("200–300 ml") { selectedWaterAmount = "200–300 ml"; activePicker = nil }
                    }
                    Button("Cancel", role: .cancel) { activePicker = nil }
                    
                    
                    
                }
            }
        }
    }
}

// MARK: - Edit Reminder Sheet
private struct EditReminderSheetView: View {
    @Binding var item: CheckboxItem
    var onDelete: () -> Void = {}
    @Environment(\.dismiss) private var dismiss

    @State private var plantName: String = ""
    @State private var selectedRoom = "Bedroom"
    @State private var selectedLight = "Full Sun"
    @State private var selectedWaterDays = "Every Day"
    @State private var selectedWaterAmount = "20–50 ml"
    @State private var activePicker: PickerType?

    enum PickerType { case room, light, waterDays, waterAmount }

    init(item: Binding<CheckboxItem>, onDelete: @escaping () -> Void = {}) {
        self._item = item
        self.onDelete = onDelete
        // Initialize state from the current item values
        _plantName = State(initialValue: item.wrappedValue.name)
        // Expecting location in format "in Room"; extract room name if possible
        let location = item.wrappedValue.location
        if let range = location.range(of: "in ") {
            _selectedRoom = State(initialValue: String(location[range.upperBound...]))
        } else {
            _selectedRoom = State(initialValue: location)
        }
        _selectedLight = State(initialValue: item.wrappedValue.sunlight)
        _selectedWaterAmount = State(initialValue: item.wrappedValue.waterAmount)
        // Keep default for water days as we don't persist it in the model
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color("BackGroundColor").ignoresSafeArea()

                VStack(spacing: 20) {
                    // Top Bar
                    HStack {
                        LiquidGlassCircleButton(systemName: "xmark", action: { dismiss() })
                        Spacer()
                        Text("Edit Reminder")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        LiquidGlassCircleButton(systemName: "checkmark", tint: Color("AccentColor"), action: {
                            let name = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !name.isEmpty else { return }
                            item.name = name
                            item.location = "in \(selectedRoom)"
                            item.sunlight = selectedLight
                            item.waterAmount = selectedWaterAmount
                            dismiss()
                        })
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    Spacer().frame(height: 60)

                    GlassTextField(text: $plantName, title: "Plant Name", placeholder: "", icon: nil)

                    GlassGroup {
                        GlassRow(title: "Room", value: selectedRoom, icon: "location", showDivider: true)
                            .onTapGesture { activePicker = .room }
                        GlassRow(title: "Light", value: selectedLight, icon: "sun.max.fill")
                            .onTapGesture { activePicker = .light }
                    }

                    GlassGroup {
                        GlassRow(title: "Watering Days", value: selectedWaterDays, icon: "drop.fill", showDivider: true)
                            .onTapGesture { activePicker = .waterDays }
                        GlassRow(title: "Water", value: selectedWaterAmount, icon: "drop.fill")
                            .onTapGesture { activePicker = .waterAmount }
                    }

                    Spacer()

                    // Delete button
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        Text("Delete Reminder")
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(LiquidGlassButtonStyle(tint: .red))
                    .padding(.horizontal, 60)
                }
                .padding(.bottom, 30)
                .confirmationDialog("Select an option", isPresented: .constant(activePicker != nil), titleVisibility: .visible) {
                    if activePicker == .room {
                        Button("Bedroom") { selectedRoom = "Bedroom"; activePicker = nil }
                        Button("Living Room") { selectedRoom = "Living Room"; activePicker = nil }
                        Button("Balcony") { selectedRoom = "Balcony"; activePicker = nil }
                        Button("Kitchen") { selectedRoom = "Kitchen"; activePicker = nil }
                        Button("Bathroom") { selectedRoom = "Bathroom"; activePicker = nil }
                    }
                    if activePicker == .light {
                        Button("Full Sun") { selectedLight = "Full Sun"; activePicker = nil }
                        Button("Partial Shade") { selectedLight = "Partial Shade"; activePicker = nil }
                        Button("Low Light") { selectedLight = "Low Light"; activePicker = nil }
                    }
                    if activePicker == .waterDays {
                        Button("Every Day") { selectedWaterDays = "Every Day"; activePicker = nil }
                        Button("Every 2 Days") { selectedWaterDays = "Every 2 Days"; activePicker = nil }
                        Button("Every 3 Days") { selectedWaterDays = "Every 3 Days"; activePicker = nil }
                        Button("Once a week") { selectedWaterDays = "Once a week"; activePicker = nil }
                        Button("Every 10 Days") { selectedWaterDays = "Every 10 Days"; activePicker = nil }
                        Button("Every 2 weeks") { selectedWaterDays = "Every 2 weeks"; activePicker = nil }
                    }
                    if activePicker == .waterAmount {
                        Button("20–50 ml") { selectedWaterAmount = "20–50 ml"; activePicker = nil }
                        Button("50–100 ml") { selectedWaterAmount = "50–100 ml"; activePicker = nil }
                        Button("100–200 ml") { selectedWaterAmount = "100–200 ml"; activePicker = nil }
                        Button("200–300 ml") { selectedWaterAmount = "200–300 ml"; activePicker = nil }
                    }
                    Button("Cancel", role: .cancel) { activePicker = nil }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TodayReminderList()
        .environmentObject(PlantStore()) // بدون أمثلة جاهزة
}


