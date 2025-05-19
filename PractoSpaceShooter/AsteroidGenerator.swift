//
//  AsteroidGenerator.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 16.05.2025.
//

import Foundation

class AsteroidGenerator: AsteroidGeneratorProtocol {
    weak var gameScene: GameSceneProtocol?
    
    var waveNumber = 0
    
    let spawnPositions = Array(stride(from: -180, through: 180, by: 45))
    let waves = Bundle.main.decode([Formation].self, from: "Formations.json")
    let asteroidTypes = Bundle.main.decode([AsteroidType].self, from: "Asteroids.json")
    
    func generateAsteroids(for gameLevel: Int, goToNextLevel: @escaping () -> Void) {
        guard let gameScene else { return }
        guard waveNumber < waves.count else {
            waveNumber = 0
            goToNextLevel()
            return
        }

        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        let maximumAsteroidType = min(asteroidTypes.count, gameLevel + 1)
        let asteroidType = Int.random(in: 0..<maximumAsteroidType)
        
        let asteroidOffset: CGFloat = 100
        let asteroidStartX = 600
        let speedIncreaseStep: CGFloat = 0.2
        
        var speedMultiplier: CGFloat {
            return switch gameLevel {
            case 1: 0.5
            case 2: 0.6
            case 3: 0.8
            case 4: 1
            case 5...8: 1
            case 9...12: 1 + CGFloat(gameLevel - 8) * speedIncreaseStep
            case 12...: 1 + CGFloat(gameLevel - 8) * speedIncreaseStep * 1.2
            default: 1
            }
        }
        
        if currentWave.asteroids.isEmpty {
            for (index, position) in spawnPositions.enumerated() {
                let asteroid = AsteroidNode(
                    type: asteroidTypes[asteroidType],
                    startPosition: CGPoint(x: asteroidStartX, y: position),
                    xOffset: asteroidOffset * CGFloat(index * 3),
                    speedMultiplier: speedMultiplier,
                    moveStraight: false
                )
                gameScene.addAsteroid(asteroid: asteroid)
            }
        } else {
            for asteroid in currentWave.asteroids {
                let asteroid = AsteroidNode(
                    type: asteroidTypes[asteroidType],
                    startPosition: CGPoint(x: asteroidStartX, y: spawnPositions[asteroid.position]),
                    xOffset: asteroidOffset * asteroid.xOffset,
                    speedMultiplier: speedMultiplier,
                    moveStraight: Int.random(in: 4...10) >= gameLevel
                )
                gameScene.addAsteroid(asteroid: asteroid)
            }
        }
    }
}
