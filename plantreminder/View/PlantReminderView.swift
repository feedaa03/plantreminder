//
//  PlantReminderView.swift
//  plantreminder
//
//  Created by Feda  on 28/10/2025.
//


import SwiftUI
import Foundation

struct PlantReminderView: View {
    var onSaved: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: PlantStore
    @EnvironmentObject private var reminderVM: PlantReminderViewModel

    @State private var activePicker: PickerType?

    enum PickerType { case room, light, waterDays, waterAmount }

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
                            let name = reminderVM.plantName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !name.isEmpty else { return }
                            reminderVM.save(to: store) {
                                onSaved()
                            }
                            dismiss()
                        })
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    Spacer().frame(height: 60)

                    GlassTextField(
                        text: $reminderVM.plantName,
                        title: "Plant Name",
                        placeholder: "",
                        icon: nil
                    )

                    GlassGroup {
                        GlassRow(title: "Room", value: reminderVM.selectedRoom, icon: "location", showDivider: true)
                            .onTapGesture { activePicker = .room }

                        GlassRow(title: "Light", value: reminderVM.selectedLight, icon: "sun.max.fill")
                            .onTapGesture { activePicker = .light }
                    }

                    GlassGroup {
                        GlassRow(title: "Watering Days", value: reminderVM.selectedWaterDays, icon: "drop.fill", showDivider: true)
                            .onTapGesture { activePicker = .waterDays }

                        GlassRow(title: "Water", value: reminderVM.selectedWaterAmount, icon: "drop.fill")
                            .onTapGesture { activePicker = .waterAmount }
                    }

                    Spacer()
                }
                .padding(.bottom, 30)
                .confirmationDialog("Select an option", isPresented: .constant(activePicker != nil), titleVisibility: .visible) {
                    if activePicker == .room {
                        Button("Bedroom") { reminderVM.selectedRoom = "Bedroom"; activePicker = nil }
                        Button("Living Room") { reminderVM.selectedRoom = "Living Room"; activePicker = nil }
                        Button("Balcony") { reminderVM.selectedRoom = "Balcony"; activePicker = nil }
                        Button("Kitchen") { reminderVM.selectedRoom = "Kitchen"; activePicker = nil }
                        Button("Bathroom") { reminderVM.selectedRoom = "Bathroom"; activePicker = nil }
                    }

                    if activePicker == .light {
                        Button("Full Sun") { reminderVM.selectedLight = "Full Sun"; activePicker = nil }
                        Button("Partial Shade") { reminderVM.selectedLight = "Partial Shade"; activePicker = nil }
                        Button("Low Light") { reminderVM.selectedLight = "Low Light"; activePicker = nil }
                    }

                    if activePicker == .waterDays {
                        Button("Every Day") { reminderVM.selectedWaterDays = "Every Day"; activePicker = nil }
                        Button("Every 2 Days") { reminderVM.selectedWaterDays = "Every 2 Days"; activePicker = nil }
                        Button("Every 3 Days") { reminderVM.selectedWaterDays = "Every 3 Days"; activePicker = nil }
                        Button("Once a week") { reminderVM.selectedWaterDays = "Once a week"; activePicker = nil }
                        Button("Every 10 Days") { reminderVM.selectedWaterDays = "Every 10 Days"; activePicker = nil }
                        Button("Every 2 weeks") { reminderVM.selectedWaterDays = "Every 2 weeks"; activePicker = nil }
                    }

                    if activePicker == .waterAmount {
                        Button("20–50 ml") { reminderVM.selectedWaterAmount = "20–50 ml"; activePicker = nil }
                        Button("50–100 ml") { reminderVM.selectedWaterAmount = "50–100 ml"; activePicker = nil }
                        Button("100–200 ml") { reminderVM.selectedWaterAmount = "100–200 ml"; activePicker = nil }
                        Button("200–300 ml") { reminderVM.selectedWaterAmount = "200–300 ml"; activePicker = nil }
                    }

                    Button("Cancel", role: .cancel) { activePicker = nil }
                }
            }
        }
    }
}

// MARK: - Sheet-local reusable components
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
                .fill(Color.white.opacity(0.08))
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
                .fill(Color.white.opacity(0.06))
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

#Preview {
    PlantReminderView()
        .environmentObject(PlantStore())
        .environmentObject(PlantReminderViewModel())
        .preferredColorScheme(.dark)
}

