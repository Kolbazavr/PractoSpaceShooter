//
//  PlayerShot.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 18.05.2025.
//

import SpriteKit

class PlayerShot: SKSpriteNode {
    
//    enum BulletType: String {
//        case laser = "Lazer"
//        case blueLaser = "BlueLaser"
//        case megaLaser = "MegaLaser"
//        case bullet = "Bullet"
//    }
    
    let damage: Int
    
    init(bulletType: String, damage: Int, angle: CGFloat) {
        let texture = SKTexture(imageNamed: bulletType)
        self.damage = damage
        
        super.init(texture: texture, color: .white, size: texture.size())
        
        name = "playerLaser"
        zPosition = -1
        zRotation = angle
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = CollisionCategory.playerBullet
        physicsBody?.collisionBitMask = CollisionCategory.asteroid
        physicsBody?.contactTestBitMask = CollisionCategory.asteroid
        physicsBody?.mass = 0.001
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
