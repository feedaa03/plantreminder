//
//  CheckboxRowView.swift
//  plantreminder
//
//  Created by Feda  on 27/10/2025.
//


import SwiftUI

public struct CheckboxRowView: View {
    public struct Item: Identifiable, Equatable {
        public let id: UUID
        public var title: String
        public var isOn: Bool

        public init(id: UUID = UUID(), title: String, isOn: Bool) {
            self.id = id
            self.title = title
            self.isOn = isOn
        }
    }

    @Binding private var isOn: Bool
    private let title: String

    public init(title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    public var body: some View {
        HStack {
            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isOn ? Color.accentColor : Color.secondary)
                .imageScale(.large)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { isOn.toggle() }
        .padding(.vertical, 8)
    }
}

#Preview {
    @Previewable @State var done = false
    return VStack {
        CheckboxRowView(title: "Watered today", isOn: $done)
        CheckboxRowView(title: "Fertilized", isOn: .constant(true))
    }
    .padding()
}
