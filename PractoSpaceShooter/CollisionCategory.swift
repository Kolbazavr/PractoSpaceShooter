//
//  CollisionCategory.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 13.05.2025.
//

import Foundation

struct CollisionCategory {
    static let player: UInt32 = 0b1
    static let playerBullet: UInt32 = 0b10
    static let asteroid: UInt32 = 0b100
    static let meteor: UInt32 = 0b1000
}
