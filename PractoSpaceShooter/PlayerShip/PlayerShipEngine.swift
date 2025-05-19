//
//  PlayerShipEngine.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 13.05.2025.
//

import SpriteKit

enum EngineType {
    case basic
    case upgraded
}

class PlayerShipEngine: SKNode {
    var engineFire: SKEmitterNode
    private var defaultEmitterRate: CGFloat = 488
    
    func startEngineFire() {
        engineFire.particleBirthRate = defaultEmitterRate
    }
    func stopEngineFire() {
        engineFire.particleBirthRate = 0
    }
    
    func setEngineType(to engineType: EngineType) {
        switch engineType {
        case .basic:
            defaultEmitterRate = 488
            engineFire.particleSpeed = 100
        case .upgraded:
            defaultEmitterRate = 1200
            engineFire.particleSpeed = 200
            engineFire.particleColorSequence = nil
            engineFire.particleLifetime = 1.2
            engineFire.particleColorBlendFactor = 1
            engineFire.particleColor = UIColor(red: 67 / 255, green: 22 / 255, blue: 72 / 255, alpha: 1)
        }
    }
    
    init(engineFire: SKEmitterNode = SKEmitterNode(fileNamed: "ShipEngineFire")!) {
        self.engineFire = engineFire
        engineFire.particleBirthRate = 0
        engineFire.position.x = -60
        super.init()
//        addChild(engineFire)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
