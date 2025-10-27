import SwiftUI

struct AllDoneView: View {
    @EnvironmentObject private var store: PlantStore
    @Environment(\.dismiss) private var dismiss
    @State private var showSheet = false
    @StateObject private var reminderVM = PlantReminderViewModel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.ignoresSafeArea()
            
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
                    
                    Image("Imageplantwink")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .frame(maxWidth: .infinity)
                    
                    Text("All Done! 🎉")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    
                    Text("All Reminders Completed")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 24)
                }
                
                Spacer()
            }
            
            // Floating + Button
            Button(action: {
                showSheet.toggle()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(color: Color.white.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 30)
            .padding(.trailing, 30)
        }
        .sheet(isPresented: $showSheet) {
            PlantReminderView(onSaved: {
                // After adding a plant, dismiss the All Done page to return to the list
                dismiss()
            })
            .environmentObject(store)
            .environmentObject(reminderVM)
        }
    }
}

// MARK: - Preview
#Preview {
    AllDoneView()
        .preferredColorScheme(.dark)
}
