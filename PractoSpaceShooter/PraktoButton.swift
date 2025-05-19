//
//  PraktoButton.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 19.05.2025.
//

import SpriteKit

class PraktoButton: SKNode {
    private var buttonRect: SKShapeNode!
    private var buttonLabel: SKLabelNode!
    var onTap: (() -> Void)
    
    init(text: String, onTap: @escaping (() -> Void)) {
        self.onTap = onTap
        super.init()
        
        self.isUserInteractionEnabled = true
        
        buttonRect = SKShapeNode(rect: CGRect(origin: .init(x: -90, y: -17), size: .init(width: 180, height: 34)), cornerRadius: 12)
        buttonRect.strokeColor = .ypWhite
        addChild(buttonRect)
        
        buttonLabel = SKLabelNode(text: text)
        buttonLabel.fontName = "VCROSDMonoRUSbyDaymarius"
        buttonLabel.fontSize = 24
        buttonLabel.fontColor = .ypWhite
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.position = .zero
        addChild(buttonLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scaleAction = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])
        self.run(scaleAction)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if buttonRect.contains(location) {
            onTap()
        }
    }
}
