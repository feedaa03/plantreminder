//
//  PlantRepository.swift
//  plantreminder
//
//  Created by Feda  on 27/10/2025.
//


import Foundation
import Combine

public protocol PlantRepository {
    func add(_ plant: Plant)
    func all() -> [Plant]
}

public final class PlantDataStore: ObservableObject, PlantRepository {
    @Published public private(set) var plants: [Plant] = []

    public init(plants: [Plant] = []) {
        self.plants = plants
    }

    public func add(_ plant: Plant) {
        plants.append(plant)
        // TODO: Persist if needed
    }

    public func all() -> [Plant] {
        plants
    }
}
