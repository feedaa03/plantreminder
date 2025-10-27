import SwiftUI
struct ContentView: View {
    @State private var showSheet = false
    @State private var navigateToList = false
    @EnvironmentObject private var store: PlantStore
    @StateObject private var reminderVM = PlantReminderViewModel()
    
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
                .contentShape(Rectangle())
                .onTapGesture { navigateToList = true }
            }
            .sheet(isPresented: $showSheet) {
                PlantReminderView(onSaved: {
                    navigateToList = true
                })
                .environmentObject(store)
                .environmentObject(reminderVM)
            }
            // Navigate to TodayReminderList when saved
            .navigationDestination(isPresented: $navigateToList) {
                TodayReminderList().environmentObject(store)
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
 
