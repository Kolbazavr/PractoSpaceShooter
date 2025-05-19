//
//  MainMenu.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 19.05.2025.
//

import SpriteKit

class MainMenu: SKScene {
    let title = SKLabelNode(text: "Practo Space Shooter")
    let buttonText = SKLabelNode(text: "New Game")
    let highScores = SKLabelNode(text: "Highest score: 0")
    let buttonRect = SKShapeNode(rect: CGRect(origin: .init(x: -90, y: -17), size: .init(width: 180, height: 34)), cornerRadius: 12)
    
    override func didMove(to view: SKView) {
        loadHighScore()
        
        let playerShip = PlayerShip(menuScene: self)
        let background = SKSpriteNode(color: .ypBlack, size: size)
        let newGameButton = PraktoButton(text: "New Game") {
            let transition = SKTransition.fade(withDuration: 2)
            let gameScene = SKScene(fileNamed: "GameScene")!
            gameScene.scaleMode = .aspectFill
            self.view?.presentScene(gameScene, transition: transition)
        }
        
        title.fontName = "VCROSDMonoRUSbyDaymarius"
        highScores.fontName = "VCROSDMonoRUSbyDaymarius"
        title.fontSize = 47
        highScores.fontSize = 14
        
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 150)
        playerShip.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
        newGameButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 108)
        highScores.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        
        addChild(title)
        addChild(playerShip)
        addChild(newGameButton)
        addChild(highScores)
        addChild(background)
        
        buttonText.name = "New Game"
        
        addFloatingMovement(node: playerShip)
        cycleUpgrades(playerShip: playerShip)
    }
    
    func addFloatingMovement(node: SKNode) {
        let moveUpAction = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1)
        let moveDownAction = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1)
        let sequence = SKAction.sequence([moveUpAction, moveDownAction])
        node.run(SKAction.repeatForever(sequence))
    }
    
    func cycleUpgrades(playerShip: PlayerShip) {
        let action1 = SKAction.run { playerShip.deploySideWeapons() }
        let action2 = SKAction.run {
            playerShip.weaponLeft.deployWeaponBarrel()
            playerShip.weaponRight.deployWeaponBarrel()
        }
        let action3 = SKAction.run {
            playerShip.weaponLeft.retractWeaponBarrel()
            playerShip.weaponRight.retractWeaponBarrel()
        }
        let action4 = SKAction.run { playerShip.retractSideWeapons() }
        let waitAction = SKAction.wait(forDuration: 1.5)
        
        let sequence = SKAction.sequence([waitAction, action1, waitAction, action2, waitAction, action3, waitAction, action4, waitAction])
        playerShip.run(SKAction.repeatForever(sequence))
    }
    
    func loadHighScore() {
        if let savedHighScore = UserDefaults.standard.object(forKey: "highScore") as? Int {
            highScores.text = "Highest score: \(savedHighScore)"
        }
    }
}
