 import SwiftUI
struct ContentView: View {
    @State private var showSheet = false
    @State private var navigateToList = false
    @EnvironmentObject private var store: PlantStore
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Plants 🌱")
                        .foregroundColor(.white)
                        .font(.largeTitle.bold())
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Main Body
                VStack(spacing: 24) {
                    Spacer().frame(height: 80)
                    
                    Image("Imageplant")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .frame(maxWidth: .infinity)
                    
                    Text("Start your plant journey!")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text("Now all your plants will be in one place and we will help you take care of them :)🪴")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.3))
                        .fontWeight(.semibold)
                        .padding(.bottom, 90)
                    
                    Button(action: { showSheet = true }) {
                        Text("Set Plant Reminder")
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(LiquidGlassButtonStyle(tint: Color("AccentColor")))
                    .padding(.horizontal, 60)
                }
                .padding()
            }
            .sheet(isPresented: $showSheet) {
                PlantReminderSheetView(onSaved: {
                    // After saving, navigate to the checklist/progress page
                    navigateToList = true
                })
                .environmentObject(store)
            }
            // Navigate to TodayReminderList when saved
            .navigationDestination(isPresented: $navigateToList) {
                TodayReminderList().environmentObject(store)
            }
        }
    }
}

// MARK: - Reminder Sheet
private struct PlantReminderSheetView: View {
    var onSaved: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: PlantStore
    
    @State private var selectedRoom = "Bedroom"
    @State private var selectedLight = "Full Sun"
    @State private var selectedWaterDays = "Every Day"
    @State private var selectedWaterAmount = "20–50 ml"
    @State private var activePicker: PickerType?
    @State private var plantName: String = ""
    
    enum PickerType {
        case room, light, waterDays, waterAmount
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color("BackGroundColor")
                    .ignoresSafeArea()
                
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
                            onSaved()
                            dismiss()
                        })
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer().frame(height: 60)
                    
                    GlassTextField(
                        text: $plantName,
                        title: "Plant Name",
                        placeholder: "",
                        icon: nil
                    )
                    
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

// MARK: - Reusable Components (بدون Glass Effect)

struct GlassTextField: View {
    @Binding var text: String
    var title: String?
    var placeholder: String
    var icon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                if let title {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                if let icon, !icon.isEmpty {
                    Image(systemName: icon)
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 18))
                }
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .disableAutocorrection(true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08)) // ← خلفية ثابتة بدون blur
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct GlassGroup<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06)) // ← بدون glass
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct GlassRow: View {
    var title: String
    var value: String
    var icon: String
    var showDivider: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.white.opacity(0.85))
                    
                    Text(title)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text(value)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.white.opacity(0.5))
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            
            if showDivider {
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.leading, 36)
            }
        }
    }
}

// MARK: - Liquid Glass Styles
struct LiquidGlassButtonStyle: ButtonStyle {
    var tint: Color = .white
    var cornerRadius: CGFloat = 23

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // Base translucent glass
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // Tint wash
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(tint.opacity(0.25))

                    // Subtle inner highlight
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .blendMode(.plusLighter)
                        .opacity(configuration.isPressed ? 0.15 : 0.3)
                }
            )
            .overlay(
                // Glass rim
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(configuration.isPressed ? 0.15 : 0.28), radius: configuration.isPressed ? 6 : 14, x: 0, y: configuration.isPressed ? 2 : 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct LiquidGlassCircleButton: View {
    var systemName: String
    var tint: Color? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(
                    ZStack {
                        Circle().fill(.ultraThinMaterial)
                        if let tint {
                            Circle().fill(tint.opacity(0.28))
                        }
                        Circle().fill(
                            AngularGradient(gradient: Gradient(colors: [Color.white.opacity(0.18), Color.clear, Color.white.opacity(0.12)]), center: .center)
                        ).blendMode(.plusLighter)
                    }
                )
                .overlay(
                    Circle().strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(PlantStore())
        .preferredColorScheme(.dark)
}
 
