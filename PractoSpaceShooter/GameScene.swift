//
//  GameScene.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 13.05.2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, GameSceneProtocol {
    let asteroidGenerator = AsteroidGenerator()
    let hud = HUDNode()
    var starField = SKEmitterNode(fileNamed: "StarField")!
    var playerShip: PlayerShip?
    var isPlayerAlive: Bool = true
    
    var score: Int = 0 { didSet { hud.updateScore(score) } }
    var highScore: Int = 0
    var level: Int = 1 { didSet { hud.updateLevel(level) } }
    var waveNumber: Int = 0
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    var destination: CGPoint?
    
    let removeAction = SKAction.sequence([
        SKAction.wait(forDuration: 2),
        SKAction.removeFromParent()
    ])
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        asteroidGenerator.gameScene = self
        hud.setupUI(size: view.frame.size)
        hud.zPosition = 100
        addChild(hud)
        
//        if let starFieldNode = SKEmitterNode(fileNamed: "StarField") {
//            starFieldNode.position = CGPoint(x: size.width, y: 0)
//            starFieldNode.zPosition = -1
//            starFieldNode.advanceSimulationTime(60)
//            self.addChild(starFieldNode)
//        }
        
        starField.position = CGPoint(x: size.width, y: 0)
        starField.zPosition = -1
        starField.advanceSimulationTime(60)
        self.addChild(starField)
        
        playerShip = PlayerShip(gameScene: self)
        playerShip?.position.x = frame.minX + 175
        playerShip?.engine.setEngineType(to: .basic)
        playerShip?.zPosition = 2
        addChild(playerShip!)
        
        showBigLetters(text: "Sprint: \(level)")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return }
        if let touch = touches.first {
            destination = touch.location(in: self)
        }
        
        playerShip?.fireAllWeapons()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return }
        if let touch = touches.first {
            destination = touch.location(in: self)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if lastUpdateTime > 1 { deltaTime = 1 / 60 }
        
        if let playerShip, let destination, playerShip.isActive {
            playerShip.fly(to: destination)
            
            for node in children where node is PowerUp {
                let powerUpNode = node as! PowerUp
                powerUpNode.pickUpIfCloseEnough(to: playerShip) { [weak self] powerUpType in
                    self?.pickUpPowerUp(powerUpType)
                    playerShip.upgrade(type: powerUpType)
                    self?.hud.update(
                        score: self?.score ?? 0,
                        health: playerShip.health,
                        level: self?.level ?? 0,
                        shipLevel: playerShip.shipLevel
                    )
                }
            }
        }
        if isPlayerAlive {
            let activeAsteroids = children.compactMap { $0 as? AsteroidNode }
            if activeAsteroids.isEmpty {
                asteroidGenerator.generateAsteroids(for: level) { [weak self] in
                    guard let self else { return }
                    self.level += 1
                    self.starField.particleSpeed += 20
                    showBigLetters(text: "Sprint: \(level)")
                }
            }
            
            let activeMeteors = children.compactMap { $0 as? MeteorNode }
            if activeMeteors.isEmpty {
                let meteorStartX: CGFloat = 600
                
                if Int.random(in: 0...7) == 0 {
                    let meteorType = MeteorType(name: "meteor", damage: 7, speed: 800)
                    let meteorStartPositionY = CGFloat.random(in: (-size.height / 2 + 30)...(size.height / 2 - 30))
                    let meteor = MeteorNode(type: meteorType, startPosition: CGPoint(x: meteorStartX, y: meteorStartPositionY))
                    
                    addChild(meteor)
                }
            }
        }
        
        removeNodesOffScreen(nodes: children)
    }
    
    func pickUpPowerUp(_ powerUpType: PowerUpType) {
        guard let playerShip = playerShip else { return }
        run(SKAction.playSoundFileNamed(powerUpType.soundName, waitForCompletion: false))
        let emitterNode = SKEmitterNode(fileNamed: powerUpType.effectName)!
        playerShip.addChild(emitterNode)
        emitterNode.run(removeAction)
    }
    
    func showBigLetters(text: String) {
        let bigLettersLabelNode = SKLabelNode(text: text)
        bigLettersLabelNode.fontName = "VCROSDMonoRUSbyDaymarius"
        bigLettersLabelNode.fontSize = 60
        bigLettersLabelNode.fontColor = .white
        bigLettersLabelNode.position = CGPoint(x: frame.midX, y: frame.midY - 200)
        bigLettersLabelNode.zPosition = 100
        addChild(bigLettersLabelNode)
        bigLettersLabelNode.run(SKAction.move(by: CGVector(dx: 0, dy: 200), duration: 1))
        bigLettersLabelNode.run(SKAction.sequence([SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
    }
    
    func addAsteroid(asteroid: AsteroidNode) {
        guard isPlayerAlive else { return }
        addChild(asteroid)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        
        switch (nodeA.name, nodeB.name) {
        case ("playerShip", "asteroid"), ("asteroid", "playerShip"):
            let asteroid = nodeA.name == "asteroid" ? nodeA : nodeB
            handlePlayerWasHit(by: asteroid as! AsteroidNode)
            
        case ("playerShip", "meteor"), ("meteor", "playerShip"):
            let meteor = nodeA.name == "meteor" ? nodeA : nodeB
            handlePlayerWasHit(by: meteor as! MeteorNode)
            
        case ("playerLaser", "asteroid"), ("asteroid", "playerLaser"):
            let playerLaser = nodeA.name == "playerLaser" ? nodeA : nodeB
            let asteroid = nodeA.name == "asteroid" ? nodeA : nodeB
            handleLaserHit(playerLaser: playerLaser as! PlayerShot, asteroid: asteroid as! AsteroidNode, contactPosition: contact.contactPoint)
        default: break
        }
    }
    
    func handleLaserHit(playerLaser: PlayerShot, asteroid: AsteroidNode, contactPosition: CGPoint) {
        let hitRotation = playerLaser.zRotation
        let damage = playerLaser.damage
        
        playerLaser.removeFromParent()
        if let hitParticle = SKEmitterNode(fileNamed: "LazerHit") {
            hitParticle.position = contactPosition
            hitParticle.zPosition = 3
            hitParticle.zRotation = hitRotation
            scene?.addChild(hitParticle)
            hitParticle.run(removeAction)
        }
        
        asteroid.health -= damage
        
        if asteroid.health <= 0 {
            let receivedScore: Int = asteroid.type.scoreAmount
            popUpNumber("+\(receivedScore)", at: asteroid.position, color: .white)
            score += receivedScore
            
            PowerUp.generatePowerUpType(from: asteroid, isEngineUpgraded: playerShip?.hasUpgradedEngine ?? true) { [weak self] generatedType in
                guard let self else { return }
                let powerUp = PowerUp(type: generatedType)
                powerUp.position = asteroid.position
                self.addChild(powerUp)
                let waitAction = SKAction.wait(forDuration: 2)
                let blinking = SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.fadeIn(withDuration: 0.2)
                ])
                let blinkingAction = SKAction.repeat(blinking, count: 7)
                let removeAction = SKAction.removeFromParent()
                powerUp.run(SKAction.sequence([waitAction, blinkingAction, removeAction]))
            }
            explodeAsteroid(asteroid)
        }
    }
    
    func handlePlayerWasHit(by asteroid: AsteroidNode) {
        destination = nil
        
        guard let playerShip else { return }
        let damage: Int = asteroid.type.hitDamage
        explodeAsteroid(asteroid)
        
        if let playerWasHitEffect = SKEmitterNode(fileNamed: "PlayerWasHit") {
            playerWasHitEffect.position = playerShip.position
            addChild(playerWasHitEffect)
            playerWasHitEffect.run(removeAction)
        }
        
        playerShip.reduceHealth(by: damage)
        hud.update(score: score, health: playerShip.health, level: level, shipLevel: playerShip.shipLevel)
        
        popUpNumber("-\(damage)", at: playerShip.position, color: .red)
        
        if playerShip.isDead {
            gameOver()
            explodePlayerShip()
        } else {
            playerShip.stun()
        }
    }
    
    func handlePlayerWasHit(by meteor: MeteorNode) {
        let damage = meteor.damage
        meteor.removeFromParent()
        
        run(SKAction.playSoundFileNamed("MeteorHit.wav", waitForCompletion: false))
        
        if let explosionNode = SKEmitterNode(fileNamed: "ExplosionMeteor"), let playerShip {
            explosionNode.position = playerShip.position
            addChild(explosionNode)
            explosionNode.run(removeAction)
        }
        
        guard let playerShip else { return }
        playerShip.reduceHealth(by: damage)
        
        hud.updateHealth(playerShip.health)
        
        popUpNumber("-\(damage)", at: playerShip.position, color: .red)
        
        if playerShip.isDead {
            gameOver()
            explodePlayerShip()
        }
    }
    
    func explodeAsteroid(_ asteroid: AsteroidNode) {
        asteroid.removeFromParent()
        
        run(SKAction.playSoundFileNamed("AsteroidExplosion.wav", waitForCompletion: false))
        
        if let explosionEffect = SKEmitterNode(fileNamed: "AsteroidExplosion") {
            explosionEffect.position = asteroid.position
            addChild(explosionEffect)
            explosionEffect.run(removeAction)
        }
    }
    
    func explodePlayerShip() {
        guard let playerShip else { return }
        
        if let explosionEffect = SKEmitterNode(fileNamed: "ShipExplosion") {
            explosionEffect.position = playerShip.position
            explosionEffect.zPosition = 3
            addChild(explosionEffect)
            explosionEffect.run(removeAction)
        }
        if let explosionBackgroundEffect = SKEmitterNode(fileNamed: "ShipExplosionBackground") {
            explosionBackgroundEffect.position = playerShip.position
            explosionBackgroundEffect.zPosition = 2
            addChild(explosionBackgroundEffect)
            explosionBackgroundEffect.run(removeAction)
        }
        playerShip.removeFromParent()
    }
    
    func popUpNumber(_ number: String, at position: CGPoint, color: UIColor) {
        let numberLabel = SKLabelNode(text: number)
        numberLabel.fontSize = 23
        numberLabel.fontName = "VCROSDMonoRUSbyDaymarius"
        numberLabel.fontColor = color
        numberLabel.position = CGPoint(x: position.x, y: position.y + 30)
        numberLabel.zPosition = 4
        addChild(numberLabel)
        numberLabel.run(SKAction.sequence([
            SKAction.move(by: .init(dx: 0, dy: 23), duration: 0.8),
            SKAction.fadeOut(withDuration: 1),
            SKAction.removeFromParent()
        ]))
    }
    
    func gameOver() {
        isPlayerAlive = false
//        removeAllActions()
//        removeAllChildren()
        
        if let highScore = UserDefaults.standard.object(forKey: "highScore") as? Int {
            if score > highScore { UserDefaults.standard.set(score, forKey: "highScore") }
        } else { UserDefaults.standard.set(score, forKey: "highScore") }
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 47
        gameOverLabel.fontName = "VCROSDMonoRUSbyDaymarius"
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
        
        let toMenuButton = PraktoButton(text: "Main Menu") {
            let menuScene = MainMenu(size: self.size)
            menuScene.scaleMode = .aspectFill
            self.view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 1))
        }
        toMenuButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        addChild(toMenuButton)
    }
}
