//
//  PowerUp.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 14.05.2025.
//

import SpriteKit

enum PowerUpType: CaseIterable {
    case health
    case engineUpgrade
    case weaponUpgrade
    
    var healAmount: Int { 12 }
    
    var imageName: String {
        switch self {
        case .health:
            return "HealthBonus.png"
        case .engineUpgrade:
            return "EngineUpgrade.png"
        case .weaponUpgrade:
            return "WeaponUpgrade.png"
        }
    }
    var effectName: String {
        switch self {
        case .health:
            return "PowerUpPickUpHealth"
        case .engineUpgrade:
            return "PowerUpPickUpWeapon" //add effect
        case .weaponUpgrade:
            return "PowerUpPickUpWeapon"
        }
    }
    var soundName: String {
        return "PowerUp.wav"
    }
    var spawnTypeChance: CGFloat {
        switch self {
        case .health: return 1
        case .weaponUpgrade: return 0.3
        case .engineUpgrade: return 0.1
        }
    }
}

class PowerUp: SKSpriteNode {
    var type: PowerUpType
    
    init(type: PowerUpType) {
        let texture = SKTexture(imageNamed: type.imageName)
        self.type = type
        super.init(texture: texture, color: .white, size: texture.size())
        
        addFloatingMovement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NOPE")
    }
    
    func addFloatingMovement() {
        let moveUpAction = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1)
        let moveDownAction = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1)
        let sequence = SKAction.sequence([moveUpAction, moveDownAction])
        run(SKAction.repeatForever(sequence))
    }
    
    func pickUpIfCloseEnough(to playerShip: PlayerShip?, with pickupAction: @escaping (PowerUpType) -> Void) {
        guard let playerShip else { return }
        
        let distance = hypot(position.x - playerShip.position.x, position.y - playerShip.position.y)
        
        if distance < playerShip.size.width / 2 {
            pickupAction(type)
            removeFromParent()
        }
    }
    
    static func generatePowerUpType(from asteroid: AsteroidNode, isEngineUpgraded: Bool, addToScene: @escaping (PowerUpType) -> Void) {
        guard Int.random(in: 0...100) < asteroid.type.powerUpChance else { return }
        let totalChance = PowerUpType.allCases.reduce(0) { $0 + $1.spawnTypeChance }
        let randomValue = CGFloat.random(in: 0...totalChance)
        var cumulativeChance: CGFloat = 0
        for type in PowerUpType.allCases {
            cumulativeChance += type.spawnTypeChance
            if randomValue <= cumulativeChance {
                if isEngineUpgraded && type == .engineUpgrade { continue }
                addToScene(type)
                break
            }
        }
    }
}
