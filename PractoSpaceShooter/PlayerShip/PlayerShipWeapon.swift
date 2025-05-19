//
//  ShipWeapon.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 13.05.2025.
//

import SpriteKit

class PlayerShipWeapon: SKSpriteNode {
    
    enum BulletType: String, CaseIterable {
        case laser = "Lazer"
        case blueLaser = "BlueLaser"
        case megaLaser = "MegaLaser"
        case bullet = "Bullet"
    }
    
    var bulletType: BulletType = .laser
    var damage: Int
    var bulletSpeed: CGFloat = 1
    let weaponSpread: CGFloat = 0.03
    let weaponBarrel = SKSpriteNode(texture: SKTexture(imageNamed: "WeaponBarrel"))
    
    init(damage: Int = 100, side: String) {
        self.damage = damage
        
        let texture: SKTexture
        switch side {
        case "default":
            texture = SKTexture() //no texture
        case "left":
            texture = SKTexture(imageNamed: "WeaponLeft")
            weaponBarrel.position = CGPoint(x: 0, y: 11)
        case "right":
            texture = SKTexture(imageNamed: "WeaponRight")
            weaponBarrel.position = CGPoint(x: 0, y: -11)
        default:
            fatalError("Wrong side parameter")
        }
         
        super.init(texture: texture, color: .white, size: texture.size())
        weaponBarrel.zPosition = -1
        addChild(weaponBarrel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func upgradeDamage() {
        damage += 10
        print("damage upgraded, new damage: \(damage)")
    }
    
    func deployWeaponBarrel() {
        let deployWeaponBarrelAction = SKAction.move(by: .init(dx: 20, dy: 0), duration: 1)
        weaponBarrel.run(deployWeaponBarrelAction)
    }
    
    func retractWeaponBarrel() {
        let retractWeaponBarrelAction = SKAction.move(by: .init(dx: -20, dy: 0), duration: 1)
        weaponBarrel.run(retractWeaponBarrelAction)
    }
    
    func upgradeBullets(to type: BulletType) {
        bulletType = type
    }
    
    func upgradeRateOfFire() {
        //make weapon shoot multiple bullets
    }
    
    func fire() {
        guard let scene = self.scene as? GameScene, let parent = self.parent else { return }

        let bullet = PlayerShot(bulletType: bulletType.rawValue, damage: damage, angle: parent.zRotation)
        bullet.position = convert(weaponBarrel.position, to: scene)
        scene.addChild(bullet)
        
        let shootDirection = parent.zRotation + CGFloat.random(in: -weaponSpread...weaponSpread)
        let dx: CGFloat = cos(shootDirection) * bulletSpeed
        let dy: CGFloat = sin(shootDirection) * bulletSpeed
        bullet.physicsBody?.applyImpulse(.init(dx: dx, dy: dy))
    }
}
