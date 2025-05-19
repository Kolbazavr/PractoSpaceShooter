//
//  GameSceneProtocol.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 13.05.2025.
//

import SpriteKit

protocol GameSceneProtocol: SKScene {
    var playerShip: PlayerShip? { get set }
    var deltaTime: TimeInterval { get }
    var destination: CGPoint? { get set }
    var level: Int { get set }
    
    func addAsteroid(asteroid: AsteroidNode)
}

