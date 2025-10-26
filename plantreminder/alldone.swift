import SwiftUI

struct AllDoneView: View {
    var body: some View {
        ZStack {
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
                .padding(.horizontal)
                
                // زر الإضافة (+)
                Button(action: { showAddPlantSheet.toggle() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(color: Color.accentColor.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
                .sheet(isPresented: $showAddPlantSheet) {
                    AllDoneView()
                        .environmentObject(store)
                        .preferredColorScheme(.dark)
                        .presentationDetents([.large])
                
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AllDoneView()
        .preferredColorScheme(.dark)
}
