//
//  MeteorNode.swift
//  PractoGame
//
//  Created by ANTON ZVERKOV on 10.05.2025.
//

import SpriteKit

class MeteorNode: SKSpriteNode {
    let type: MeteorType
    let damage: Int
    
    init(type: MeteorType, startPosition: CGPoint) {
        self.type = type
        damage = type.damage
        
        let texture = SKTexture(imageNamed: "Meteor") // ADD NAMES
        super.init(texture: texture, color: .white, size: texture.size())
        
        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody?.categoryBitMask = CollisionCategory.meteor
        physicsBody?.collisionBitMask = CollisionCategory.player
        
        name = "meteor"
        position = CGPoint(x: startPosition.x, y: startPosition.y)
        
        configure()
        
        //tail animation
        let particleEmitter = SKEmitterNode(fileNamed: "MeteorTail")!
        particleEmitter.advanceSimulationTime(3)
        addChild(particleEmitter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NOPE")
    }
    
    func configure() {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: -10000, y: 0))
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, speed: type.speed)
        let sequence = SKAction.sequence([movement, SKAction.removeFromParent()])
        run(sequence)
    }
}
