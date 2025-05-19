//
//  AsteroidNode.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 14.05.2025.
//

import SpriteKit

class AsteroidNode: SKSpriteNode {
    var health: Int
    let type: AsteroidType
    
    init(type: AsteroidType, startPosition: CGPoint, xOffset: CGFloat, speedMultiplier: CGFloat, moveStraight: Bool) {
        self.health = type.health
        self.type = type
        let texture = SKTexture(imageNamed: type.name)
        super.init(texture: texture, color: .white, size: texture.size())
        
        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody?.allowsRotation = true
        physicsBody?.angularDamping = 0.5
        physicsBody?.angularVelocity = CGFloat.random(in: -1...1)
        physicsBody?.categoryBitMask = CollisionCategory.asteroid
        physicsBody?.collisionBitMask = CollisionCategory.playerBullet | CollisionCategory.player
        
        name = "asteroid"
        position = CGPoint(x: startPosition.x + xOffset, y: startPosition.y)
        
        configure(speedMultiplier: speedMultiplier, withMovement: moveStraight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(speedMultiplier: CGFloat, withMovement moveStraight: Bool) {
        let path = UIBezierPath()
        path.move(to: .zero)
        
        if moveStraight {
            path.addLine(to: CGPoint(x: -10000, y: 0))
        } else {
//            let point1: CGPoint = .init(x: -3500, y: -position.y)
//            let point2: CGPoint = .init(x: -200, y: position.y * 2 * CGFloat.random(in: -1...1))
//            let point3: CGPoint = .init(x: -400, y: position.y)
            
            let randomY: CGFloat = position.y * 2 * CGFloat.random(in: -1...1)
            let point1: CGPoint = .init(x: -3500, y: -position.y)
            let point2: CGPoint = .init(x: 200, y: randomY)
            let point3: CGPoint = .init(x: -200, y: -randomY)
            
            path.addCurve(to: point1, controlPoint1: point2, controlPoint2: point3)
        }
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, speed: type.speed * speedMultiplier)
        let sequence = SKAction.sequence([movement, SKAction.removeFromParent()])
        run(sequence)
    }
}
