//
//  AsteroidType.swift
//  PractoGame
//
//  Created by ANTON ZVERKOV on 09.05.2025.
//

import SpriteKit

struct AsteroidType: Codable {
    let name: String
    let health: Int
    let speed: CGFloat
    let powerUpChance: Int
    let hitDamage: Int
    let scoreAmount: Int
}
