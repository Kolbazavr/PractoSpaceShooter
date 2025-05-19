//
//  AsteroidGeneratorProtocol.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 16.05.2025.
//

import Foundation

protocol AsteroidGeneratorProtocol {
    func generateAsteroids(for gameLevel: Int, goToNextLevel: @escaping () -> Void)
}
