//
//  PlayerShip.swift
//  PractoGame
//
//  Created by ANTON ZVERKOV on 13.05.2025.
//

import SpriteKit

class PlayerShip: SKSpriteNode {
    
    weak var gameScene: GameSceneProtocol?
    
    var engine = PlayerShipEngine()
    var shipLevel: Int = 0
    var isDead: Bool = false
    var isActive: Bool = true
    var health: Int = 100
    var hasUpgradedEngine: Bool = false
    var activeWeapons: [PlayerShipWeapon] = []
    var shipSpeed: CGFloat = 200

    var fireSoundEffectSource: String?
    
    let maxHealth: Int = 100
    let rotationSpeed: CGFloat = 0.07
    
    let weaponDefault = PlayerShipWeapon(side: "default")
    let weaponLeft = PlayerShipWeapon(side: "left")
    let weaponRight = PlayerShipWeapon(side: "right")
    
    let smokeParticleEmitter = SKEmitterNode(fileNamed: "ShipSmoke")!
    let defaultSmokeRate: CGFloat = 20
    
    init(gameScene: GameSceneProtocol) {
        self.gameScene = gameScene
        self.fireSoundEffectSource = "Shot1.wav"
        let texture = SKTexture(imageNamed: "PlayerShip")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        weaponDefault.position = CGPoint(x: 0, y: 0)
        addChild(weaponDefault)
        weaponLeft.isHidden = true
        weaponLeft.zPosition = -1
        addChild(weaponLeft)
        weaponRight.isHidden = true
        weaponRight.zPosition = -1
        addChild(weaponRight)
        
        smokeParticleEmitter.particleBirthRate = 0
        addChild(smokeParticleEmitter)
        
        engine.engineFire.targetNode = gameScene
        self.addChild(engine.engineFire)
        
        activeWeapons.append(weaponDefault)
        
        name = "playerShip"
        zPosition = 2
        
        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody?.categoryBitMask = CollisionCategory.player
        physicsBody?.collisionBitMask = CollisionCategory.asteroid | CollisionCategory.meteor
        physicsBody?.contactTestBitMask = CollisionCategory.asteroid | CollisionCategory.meteor
        physicsBody?.isDynamic = false
    }
    
    init(menuScene: MainMenu) {
        let texture = SKTexture(imageNamed: "PlayerShip")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        weaponDefault.position = CGPoint(x: 0, y: 0)
        addChild(weaponDefault)
        weaponLeft.isHidden = true
        weaponLeft.zPosition = -1
        addChild(weaponLeft)
        weaponRight.isHidden = true
        weaponRight.zPosition = -1
        addChild(weaponRight)
        
        name = "playerShip"
        zPosition = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fly(to destination: CGPoint?) {
        guard isActive else { return }
        guard let gameScene else { return }
        guard let destination else { return }
 
        let toDestination = CGVector(
            dx: destination.x - position.x,
            dy: destination.y - position.y
        )
        
        let distance = hypot(toDestination.dx, toDestination.dy)
        
        var rotationSpeedBoost: CGFloat {
            max(min(frame.width / distance, 1.5), 1)
        }
        
        let angleRadians = atan2(toDestination.dy, toDestination.dx)
        let shortest = atan2(sin(angleRadians - zRotation), cos(angleRadians - zRotation))
        
        if distance < 15 || (distance < 60 && abs(shortest) > 1.7) {
            engine.stopEngineFire()
            gameScene.destination = nil
            return
        } else {
            engine.startEngineFire()
        }
        
        zRotation += shortest * rotationSpeed * rotationSpeedBoost
        
        let maxSpeed = shipSpeed
        let minSpeed = shipSpeed * 0.2
        let speedFalloffDistance: CGFloat = 150
        
        let speedScale = 1 - pow(1 - min(distance/speedFalloffDistance, 1), 2)
        let currentSpeed = minSpeed + (maxSpeed - minSpeed) * speedScale
        
        let dx = cos(zRotation) * currentSpeed * CGFloat(gameScene.deltaTime)
        let dy = sin(zRotation) * currentSpeed * CGFloat(gameScene.deltaTime)
        
        engine.engineFire.emissionAngle = (zRotation - .pi) - shortest * 1.5
        
        position.x += dx
        position.y += dy
    }
    
    func stun() {
        smokeParticleEmitter.particleBirthRate = defaultSmokeRate
        isActive = false
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run { [weak self] in
                self?.isActive = true
                self?.smokeParticleEmitter.particleBirthRate = 0
            }]))
    }
    
    func reduceHealth(by amount: Int) {
        self.health = max(self.health - amount, 0)
        self.isDead = self.health <= 0
    }
    
    func heal(by amount: Int) {
        self.health = min(self.health + amount, maxHealth)
    }
    
    func fireAllWeapons() {
        if let fireSoundEffectSource {
            run(SKAction.playSoundFileNamed(fireSoundEffectSource, waitForCompletion: false))
        }
        for weapon in activeWeapons {
            weapon.fire()
        }
    }
    
    func deploySideWeapons() {
        weaponLeft.isHidden = false
        weaponRight.isHidden = false
        let moveLeftAction = SKAction.move(by: .init(dx: 0, dy: 23), duration: 1)
        let moveRightAction = SKAction.move(by: .init(dx: 0, dy: -23), duration: 1)
        weaponLeft.run(moveLeftAction)
        weaponRight.run(moveRightAction)
    }
    
    func retractSideWeapons() {
//        weaponLeft.isHidden = true
//        weaponRight.isHidden = true
        let moveLeftAction = SKAction.move(by: .init(dx: 0, dy: 23), duration: 1)
        let moveRightAction = SKAction.move(by: .init(dx: 0, dy: -23), duration: 1)
        weaponLeft.run(moveRightAction)
        weaponRight.run(moveLeftAction)
        
    }
    
    func upgrade(type: PowerUpType) {
        switch type {
        case .health:
            heal(by: type.healAmount)
        case .engineUpgrade:
            upgradeEngine()
        case .weaponUpgrade:
            upgradeWeapons()
        }
    }
    
    func upgradeEngine() {
        engine.setEngineType(to: .upgraded)
        hasUpgradedEngine = true
        self.shipSpeed += 100
    }
    
    func upgradeWeapons() {
        print("Weapons upgraded!")
        shipLevel += 1
        switch shipLevel {
        case 0:
            return
        case 1:
            deploySideWeapons()
            activeWeapons = [weaponLeft, weaponRight]
        case 2:
            activeWeapons.append(weaponDefault)
        case 3:
            weaponLeft.deployWeaponBarrel()
            weaponRight.deployWeaponBarrel()
            weaponLeft.upgradeBullets(to: .blueLaser)
            weaponRight.upgradeBullets(to: .blueLaser)
            fireSoundEffectSource = "Shot2.wav"
        case 4...7:
            for weapon in activeWeapons {
                weapon.upgradeDamage()
            }
        case 8:
            weaponLeft.upgradeBullets(to: .megaLaser)
            weaponRight.upgradeBullets(to: .megaLaser)
            for weapon in activeWeapons {
                weapon.upgradeDamage()
            }
        case 9...12:
            for weapon in activeWeapons {
                weapon.upgradeDamage()
            }
        case 13:
            weaponDefault.upgradeBullets(to: .megaLaser)
            for weapon in activeWeapons {
                weapon.upgradeDamage()
            }
        case 14...100:
            for weapon in activeWeapons {
                weapon.upgradeDamage()
            }
        default:
            break
        }
    }
    
    func reset() {
        //set all to basic
    }
}
