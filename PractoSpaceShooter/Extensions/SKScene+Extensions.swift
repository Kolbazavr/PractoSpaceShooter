//
//  SKScene+Extensions.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 14.05.2025.
//

import SpriteKit

extension SKScene {
    func removeNodesOffScreen(nodes: [SKNode], buffer: CGFloat = 1000) {
        let sceneRect = CGRect(x: -buffer,
                               y: -buffer,
                               width: size.width + buffer * 2,
                               height: size.height + buffer * 2)
        
        for node in nodes where node is SKEmitterNode == false {
            let nodePositionInScene = convert(node.position, from: node.parent!)
            if !sceneRect.contains(nodePositionInScene) {
                node.removeFromParent()
            }
        }
    }
}
