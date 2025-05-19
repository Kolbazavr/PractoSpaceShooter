//
//  Formation.swift
//  PractoGame
//
//  Created by ANTON ZVERKOV on 09.05.2025.
//

import SpriteKit

struct Formation: Codable {
    struct Asteroid: Codable {
        let position: Int
        let xOffset: CGFloat
        let moveStraight: Bool
    }
    
    let name: String
    let asteroids: [Asteroid]
}
