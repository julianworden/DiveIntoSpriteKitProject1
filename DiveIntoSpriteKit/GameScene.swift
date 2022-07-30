//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "player-rocket.png")
    var music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")

    var touchingPlayer = false
    var gameTimer: Timer?
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    override func didMove(to view: SKView) {
        // this method is called when your game scene is ready to run

        let background = SKSpriteNode(imageNamed: "space.jpg")
        background.zPosition = -1
        addChild(background)
        addChild(music)

        if let particles = SKEmitterNode(fileNamed: "SpaceDust") {
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            addChild(particles)
        }

        player.position.x = -400
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 1
        addChild(player)

        score = 0

        scoreLabel.zPosition = 2
        scoreLabel.position.y = 300
        addChild(scoreLabel)

        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        physicsWorld.contactDelegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen

        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        if tappedNodes.contains(player) {
            touchingPlayer = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchingPlayer else { return }
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        player.position = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen

        touchingPlayer = false
    }

    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered

        for node in children {
            if node.position.x < -700 {
                node.removeFromParent()
            }
        }

        if player.parent != nil {
            score += 1
        }

        if player.position.x < -400 {
            player.position.x = -400
        } else if player.position.x > 400 {
            player.position.x = 400
        }

        if player.position.y < -300 {
            player.position.y = -300
        } else if player.position.y > 300 {
            player.position.y = 300
        }
    }

    func createEnemy() {
        let sprite = SKSpriteNode(imageNamed: "enemy-ship.png")
        sprite.position = CGPoint(x: 1200, y: Int.random(in: -350...350))
        sprite.name = "enemy"
        sprite.zPosition = 1
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: -1000, dy: 0)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.categoryBitMask = 0
        addChild(sprite)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerHit(nodeB)
        } else {
            playerHit(nodeA)
        }
    }

    func playerHit(_ node: SKNode) {
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = player.position
            explosion.zPosition = 3
            addChild(explosion)
        }

        player.removeFromParent()
        music.removeFromParent()

        let gameOver = SKSpriteNode(imageNamed: "gameOver-1")
        gameOver.zPosition = 10
        addChild(gameOver)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }

        let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(sound)
    }
}

