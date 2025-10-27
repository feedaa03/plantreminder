//
//  Plant.swift
//  plantreminder
//
//  Created by Feda  on 27/10/2025.
//


import Foundation

public struct Plant: Identifiable, Equatable, Codable {
    public let id: UUID
    public var name: String
    public var room: String
    public var light: String
    public var wateringDays: String
    public var waterAmount: String

    public init(
        id: UUID = UUID(),
        name: String,
        room: String,
        light: String,
        wateringDays: String,
        waterAmount: String
    ) {
        self.id = id
        self.name = name
        self.room = room
        self.light = light
        self.wateringDays = wateringDays
        self.waterAmount = waterAmount
    }
}
