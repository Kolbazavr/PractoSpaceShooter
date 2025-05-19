//
//  HUD.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 17.05.2025.
//

import SpriteKit

class HUDNode: SKNode {
    private let scoreLabel = SKLabelNode(fontNamed: "VCROSDMonoRUSbyDaymarius")
    private let healthBar = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 10))
    private let levelIndicator = SKLabelNode(fontNamed: "VCROSDMonoRUSbyDaymarius")
    private let shipLevelIndicator = SKLabelNode(fontNamed: "VCROSDMonoRUSbyDaymarius")
    
    func setupUI(size: CGSize) {
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        addChild(scoreLabel)
        
        setupHealthBar(size: size)
        
        levelIndicator.text = "Sprint: 1"
        levelIndicator.fontSize = 20
        levelIndicator.horizontalAlignmentMode = .right
        levelIndicator.position = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y - 30)
        addChild(levelIndicator)
        
        shipLevelIndicator.text = "Ship Level: 0"
        shipLevelIndicator.fontSize = 20
        shipLevelIndicator.horizontalAlignmentMode = .left
        shipLevelIndicator.position = CGPoint(x: healthBar.position.x, y: healthBar.position.y - 30)
        addChild(shipLevelIndicator)
    }
    
    private func setupHealthBar(size: CGSize) {
        let backgroundBar = SKSpriteNode(color: .gray, size: CGSize(width: 200, height: 10))
        backgroundBar.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundBar.position = CGPoint(x: -size.width / 2, y: size.height / 2 - 20)
        addChild(backgroundBar)
        
        healthBar.anchorPoint = CGPoint(x: 0, y: 0)
        healthBar.position = backgroundBar.position
        healthBar.zPosition = 1
        addChild(healthBar)
        
        let border = SKShapeNode(rect: CGRect(origin: CGPoint(x: backgroundBar.position.x - 2, y: backgroundBar.position.y - 2), size: CGSize(width: 204, height: 14)))
        border.strokeColor = .white
        border.lineWidth = 2
        border.fillColor = .clear
        addChild(border)
    }
    
    func updateScore(_ score: Int) {
        let changeAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        scoreLabel.run(changeAction) {
            self.scoreLabel.text = "Score: \(score)"
        }
    }
    
    func updateHealth(_ health: Int) {
        let healthPercentage = max(0, min(1, CGFloat(health) / 100.0))
        healthBar.xScale = healthPercentage
        
        if healthPercentage < 0.3 {
            let blinkRed = SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.15),
                SKAction.colorize(with: .white, colorBlendFactor: 0.0, duration: 0.15)
            ])
            healthBar.run(SKAction.repeatForever(blinkRed), withKey: "healthBlink")
        } else {
            healthBar.removeAction(forKey: "healthBlink")
            healthBar.color = UIColor(
                red: min(1.0, 2.0 - healthPercentage * 2.0),
                green: min(1.0, healthPercentage * 2.0),
                blue: 0,
                alpha: 1
            )
        }
        
//        let healthColor = UIColor(
//            red: min(1.0, 2.0 - healthPercentage * 2.0),
//            green: min(1.0, healthPercentage * 2.0),
//            blue: 0,
//            alpha: 1
//        )
//        healthBar.color = healthColor
    }
    
    func updateLevel(_ level: Int) {
        levelIndicator.text = "Sprint: \(level)"
    }
    
    private func updateShipLevel(_ shiplevel: Int) {
        shipLevelIndicator.text = "Ship Level: \(shiplevel)"
    }
    
    func update(score: Int, health: Int, level: Int, shipLevel: Int) {
        updateScore(score)
        updateHealth(health)
        updateLevel(level)
        updateShipLevel(shipLevel)
    }
    
    
}
