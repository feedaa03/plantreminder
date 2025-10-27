//
//  Reminder.swift
//  plantreminder
//
//  Created by Feda  on 27/10/2025.
//


import Foundation

public struct Reminder: Identifiable, Equatable, Codable {
    public let id: UUID
    public var plantID: UUID
    public var scheduleDescription: String

    public init(
        id: UUID = UUID(),
        plantID: UUID,
        scheduleDescription: String
    ) {
        self.id = id
        self.plantID = plantID
        self.scheduleDescription = scheduleDescription
    }
}
