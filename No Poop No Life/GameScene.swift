//
//  GameScene.swift
//  No Poop No Life
//
//  Created by wenlong qiu on 8/4/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

//attributions: the jellyfish image made by vecteezy at www.vecteezy.com, the tap Icon made by Freepik from www.flaticon.com, ocean image made by pixabay but dont need attribution
//water splash sound by Hampusnoren at https://freesound.org/s/147182/ had cut
//electrocted man sound by balloonhead at www.freesound.org //no attributon required
//ding sound by InspectorJ at https://freesound.org/s/411088/, had cut
//down arrow Icon made by Pixel perfect from www.flaticon.com 
import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate{
    
    let defaults = UserDefaults.standard
    var best : Int = 0
    //    private var label : SKLabelNode?
    //    private var spinnyNode : SKShapeNode?
    var troll : SKSpriteNode?
    var topBite : SKSpriteNode?
    var botBite : SKSpriteNode?
    var leftEdge : SKSpriteNode?
    var rightEdge : SKSpriteNode?
    var topEdge : SKSpriteNode?
    var botEdge : SKSpriteNode?
    let trollCategory : UInt32 = 0x1 << 1
    let topBiteCategory : UInt32 = 0x1 << 2
    let botBiteCategory : UInt32 = 0x1 << 3
    let poopCategory : UInt32 = 0x1 << 4
    let edgeCategory : UInt32 = 0x1 << 5
    //gravity
    let gravityCategory : UInt32 = 0x1 << 6
    let reverseGravityCategory: UInt32 = 0x1 << 7
    //score contact sprites on both sides
    let scoreCategory: UInt32 = 0x1 << 8
    //when top Bite or bot Bite bitten the punish contact
    let punishCategory: UInt32 = 0x1 << 9

    var rotateCounterClock : SKAction?
    var topBiteUp : SKAction?
    var botBiteDown : SKAction?
    
    //timers
    var poopTimer : Timer?
    var poopDelay : Timer?
    
    //scorer
    var leftContact : SKSpriteNode?
    var rightContact : SKSpriteNode?
    var score : Int = 0
    var scoreBoard : SKLabelNode?
    
    //shark bite gameover
    var midContact : SKSpriteNode?
    
    //
    var backGround : SKSpriteNode?
    var light : SKLightNode?
    //lights
    var lightTop : SKLightNode?
    var lightBot : SKLightNode?
    var lightLeft : SKLightNode?
    
    
    //check whether it is user's first tap of the game
    var tutorStage : Int = 3
    var poop : SKSpriteNode?
    var tutorial : Bool = true
    
    var diverTexture : SKSpriteNode?

    //elements on the gameover board
    var gameBoard : SKSpriteNode?
    var bestScore : SKLabelNode?
    var thisScore : SKLabelNode?
    var rankScore : SKLabelNode?
    
    var audioPlayer : AVAudioPlayer!
    let diverSound = Bundle.main.url(forResource: "diverSplash", withExtension: "mp3")
    let buzzSound = Bundle.main.url(forResource: "buzz", withExtension: "wav")
    let dingSound = Bundle.main.url(forResource: "ding", withExtension: "wav")
    let biteSound = Bundle.main.url(forResource: "biteSound", withExtension: "aiff")
    let biteSound2 = Bundle.main.url(forResource: "biteSound2", withExtension: "wav")
    //diver's animation
    let diverTexture1 = SKTexture(imageNamed: "diver")
    let diverTexture2 = SKTexture(imageNamed: "diverE")
    //one animation
    var animation = SKAction()
    //repeated animation
    var strike = SKAction()
    
    //jelly's animation
    let jellyTexture1 = SKTexture(imageNamed: "Jellyfish4")
    let jellyTextureFliped1 = SKTexture(imageNamed: "jellyfish5")
    let jellyTexture2Fliped2 = SKTexture(imageNamed: "jellyfishFliped5")
    let jellyTextureRed = SKTexture(imageNamed: "jellyfishRed1")
    var jellyAnimation = SKAction()
    
    //let diverSound = SKAction.playSoundFileNamed("diverSplash.mp3", waitForCompletion: true)
    //let diverSound = SKAudioNode(fileNamed: "diverSplash.mp3")
    
    var gameOver : Bool = false
    
    var restartButton : SKSpriteNode?
    //action makes board visible when gameover
    let opacityAction = SKAction.fadeIn(withDuration: 1.5)
    
    //tutorial
    var tapIcon : SKSpriteNode?
    var tapText : SKLabelNode?
    
    //lightBox blind dodge double points
    var points : Int = 2
    var lightBox : SKSpriteNode?
    override func didMove(to view: SKView) {
        UIScreen.main.brightness = 50
        physicsWorld.contactDelegate = self
        setUpGame()
    }
    //right texture
    let ringsArray : [SKTexture] = [SKTexture(imageNamed: "Saphire1"), SKTexture(imageNamed: "Ruby1"),SKTexture(imageNamed: "Gold1"),SKTexture(imageNamed: "Silver1"),SKTexture(imageNamed: "Bronze1")]
    var ring : SKSpriteNode?
    func setUpGame() {
        //scuba diver animation setup
        animation = SKAction.animate(with: [diverTexture2, diverTexture1], timePerFrame: 0.1)
        //jelly animation
        //jellyAnimation = SKAction.animate(with: [jellyTexture1, jellyTextureFliped1], timePerFrame: 0.3)
        jellyAnimation = SKAction.animate(with: [jellyTexture1, jellyTextureRed], timePerFrame: 0.3)

        strike = SKAction.repeat(animation, count: 3)
        
        best = defaults.integer(forKey: "best")
        backGround = childNode(withName: "backGround") as? SKSpriteNode
        backGround?.zPosition = -1
        backGround?.lightingBitMask = 1
        backGround?.shadowCastBitMask = 0
        backGround?.shadowedBitMask = 1
        //let backGround = SKSpriteNode(imageNamed: "backGround")
        
        // Get label node from scene and store it for use later
        troll = childNode(withName: "troll") as? SKSpriteNode
        troll?.physicsBody?.categoryBitMask = trollCategory
        troll?.physicsBody?.contactTestBitMask = topBiteCategory | botBiteCategory | poopCategory
        troll?.physicsBody?.collisionBitMask = 0 // only dummy can exert force/effect on troll
        //topBite bouces because its not pinned, edges are pinned
        troll?.color = UIColor.clear
        
        gameBoard = childNode(withName: "board") as? SKSpriteNode
        bestScore = gameBoard?.childNode(withName: "bestScore") as? SKLabelNode
        thisScore = gameBoard?.childNode(withName: "thisScore") as? SKLabelNode
        rankScore = gameBoard?.childNode(withName: "rank") as? SKLabelNode
        restartButton = gameBoard?.childNode(withName: "restart") as? SKSpriteNode
        restartButton?.color = UIColor.clear
        ring = gameBoard?.childNode(withName: "ring") as? SKSpriteNode
        let zeroAlpha = SKAction.fadeAlpha(to: 0, duration: 0.01)
        troll?.run(strike)
        gameBoard?.run(SKAction.sequence([opacityAction, zeroAlpha]))
        gameBoard?.removeAllActions()
        
        opacityZero()
        
        //        topBite = SKSpriteNode.init(texture: SKTexture(imageNamed: "SHARK_TEETH01"), size: CGSize(width: 1364, height: 126.339))
        topBite = childNode(withName: "topBite") as? SKSpriteNode
        topBite?.color = UIColor.clear
        topBite?.physicsBody?.categoryBitMask = topBiteCategory
        topBite?.physicsBody?.contactTestBitMask = trollCategory | botBiteCategory | punishCategory
        topBite?.physicsBody?.collisionBitMask = trollCategory
        //maybe not
        //topBite?.physicsBody?.usesPreciseCollisionDetection = true
        //topBite?.physicsBody?.collisionBitMask = edgeCategory | botBiteCategory
        
        //lighting
        topBite?.lightingBitMask = 1
        topBite?.shadowCastBitMask = 0
        topBite?.shadowedBitMask = 1
        
        
        
        //        topBite?.centerRect = CGRect(x: -1, y: 383.169, width: 1364, height: 126.339)
        //        topBite?.texture = SKTexture(imageNamed: "SHARK_TEETH01")
        
        
        botBite = childNode(withName: "botBite") as? SKSpriteNode
        botBite?.color = UIColor.clear
        botBite?.physicsBody?.categoryBitMask = botBiteCategory
        botBite?.physicsBody?.contactTestBitMask = trollCategory | topBiteCategory | punishCategory
        botBite?.physicsBody?.collisionBitMask = trollCategory
        //maybe not
        //botBite?.physicsBody?.usesPreciseCollisionDetection = true
        //botBite?.physicsBody?.collisionBitMask = edgeCategory | topBiteCategory
        
        //lighting
        botBite?.lightingBitMask = 1
        botBite?.shadowCastBitMask = 0
        botBite?.shadowedBitMask = 1
        
        //texture
        //        let sharkTop = childNode(withName: "sharkTop") as? SKSpriteNode
        //        sharkTop?.lightingBitMask = 1
        //        sharkTop?.shadowCastBitMask = 0
        //        sharkTop?.shadowedBitMask = 1
        
        //        let sharkBot = childNode(withName: "sharkBot") as? SKSpriteNode
        //        sharkBot?.lightingBitMask = 1
        //        sharkBot?.shadowCastBitMask = 0
        //        sharkBot?.shadowedBitMask = 1
        
        //lights
        lightTop = troll?.childNode(withName: "lightTop") as? SKLightNode
        lightBot = troll?.childNode(withName: "lightBot") as? SKLightNode
        lightLeft = troll?.childNode(withName: "lightLeft") as? SKLightNode
        lightEnable(enable: false)
        
        
        
        leftEdge = childNode(withName: "leftEdge") as? SKSpriteNode
        leftEdge?.physicsBody?.categoryBitMask = edgeCategory
        leftEdge?.physicsBody?.contactTestBitMask = 0
        leftEdge?.physicsBody?.collisionBitMask = 0
        
        
        rightEdge = childNode(withName: "rightEdge") as? SKSpriteNode
        rightEdge?.physicsBody?.categoryBitMask = edgeCategory
        rightEdge?.physicsBody?.contactTestBitMask = 0
        rightEdge?.physicsBody?.collisionBitMask = 0
        
        topEdge = childNode(withName: "topEdge") as? SKSpriteNode
        topEdge?.physicsBody?.categoryBitMask = edgeCategory
        
        botEdge = childNode(withName: "botEdge") as? SKSpriteNode
        botEdge?.physicsBody?.categoryBitMask = edgeCategory
        
        //actions
        rotateCounterClock = SKAction.rotate(byAngle: CGFloat.pi / 3, duration: 0.06)
        //topBiteUp = SKAction.moveTo(y: (troll?.position.y)!, duration: 0.01)
        //botBiteDown = SKAction.moveTo(y: (botBite?.position.y)!, duration: 0.01)
        //topBiteUp = SKAction.moveBy(x: 0, y: 60 , duration: 0.01)
        //botBiteDown = SKAction.moveBy(x: 0, y: -60 , duration: 0.01)
        
        //gravity
        let gravity = SKFieldNode.linearGravityField(withVector: vector3(0, -8.8, 0))
        //gravity.strength = 6
        gravity.categoryBitMask = gravityCategory
        addChild(gravity)
        
        let reverseGravity = SKFieldNode.linearGravityField(withVector: vector3(0, 8.8, 0))
        //reverseGravity.strength = -6
        reverseGravity.categoryBitMask = reverseGravityCategory
        addChild(reverseGravity)
        
        topBite?.physicsBody?.fieldBitMask = gravityCategory
        botBite?.physicsBody?.fieldBitMask = reverseGravityCategory
        
        leftContact = childNode(withName: "leftContact") as? SKSpriteNode
        leftContact?.color = UIColor.clear
        //leftContact?.isHidden = true
        //leftContact?.physicsBody?.isDynamic = false
        leftContact?.physicsBody?.categoryBitMask = scoreCategory
        leftContact?.physicsBody?.contactTestBitMask = poopCategory
        //leftContact?.physicsBody?.collisionBitMask = 0
        
        rightContact = childNode(withName: "rightContact") as? SKSpriteNode
        rightContact?.color = UIColor.clear
        //rightContact?.isHidden = true
        //rightContact?.physicsBody?.isDynamic = false
        rightContact?.physicsBody?.categoryBitMask = scoreCategory
        rightContact?.physicsBody?.contactTestBitMask = poopCategory
        //rightContact?.physicsBody?.collisionBitMask = 0
        
        midContact = childNode(withName: "midContact") as? SKSpriteNode
        midContact?.color = UIColor.clear
        //midContact?.isHidden = true
        midContact?.physicsBody?.categoryBitMask = punishCategory
        midContact?.physicsBody?.contactTestBitMask = topBiteCategory | botBiteCategory
        midContact?.zPosition = (topBite?.zPosition)!
        
        scoreBoard = childNode(withName: "score") as? SKLabelNode
        
        scoreBoard?.text = String(score)
        
        
        
        //light?.falloff = -4
        //restartButton?.restartButtonDelegate = self
        //restartButton?.isUserInteractionEnabled = true
        
        createAJelly(right: true, tutorial: true)
        
        //find the note for diver texture
        //diverTexture = troll?.childNode(withName: "diver") as? SKSpriteNode
        //addChild(diverSound)
        
        diverTexture = troll?.childNode(withName: "diverTexture") as? SKSpriteNode
        
        //tuturoial
        tapIcon = childNode(withName: "tapIcon") as? SKSpriteNode
        tapText = childNode(withName: "tapText") as? SKLabelNode
        
        lightBox = troll?.childNode(withName: "lightBox") as? SKSpriteNode
        lightBox?.color = UIColor.clear
        
        print("\(troll?.zRotation), \(CGFloat.pi)")
        
    }
    
    func opacityZero() {
        gameBoard?.alpha = 0
        bestScore?.alpha = 0
        thisScore?.alpha = 0
        rankScore?.alpha = 0
        ring?.alpha = 0
    }
    
    //create jellyfishes for the rest of the game after tutorial
    func beginCreateJelly() {
        var tutorIn = true
        var time : Double = 4
        poopTimer = Timer.scheduledTimer(withTimeInterval: 3.6, repeats: true, block: { (timer) in
            if arc4random_uniform(2) == 1 {
                time = 0.1
            } else {
                time = 0.4
            }
//            if tutorIn == true {
//                time = 3.3
//                //set tutorial = false only after left side tutor jelly fish created
//                tutorIn = false
//            }
            print(time)
            self.poopDelay = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { (timer) in
                if tutorIn == true {
                    self.createAJelly(right: false, tutorial: false)
                    tutorIn = false
                } else {
                    if arc4random_uniform(2) == 1 {
                        self.createAJelly(right: false, tutorial: false)
                    } else {
                        self.createAJelly(right: true, tutorial: false)
                    }
                }
                
            })
        })
    }

    func lightEnable(enable : Bool) {
        lightTop?.isEnabled = enable
        lightBot?.isEnabled = enable
        lightLeft?.isEnabled = enable
    }
    func createAJelly(right : Bool, tutorial : Bool) {
        points = 2
        poop = SKSpriteNode(imageNamed: "Jellyfish4")
        poop?.name = "poop"
        addChild(poop!)
        poop?.physicsBody = SKPhysicsBody(rectangleOf: (poop?.size)!)
        poop?.physicsBody?.categoryBitMask = poopCategory
        poop?.physicsBody?.affectedByGravity = false
        poop?.physicsBody?.contactTestBitMask = trollCategory | scoreCategory

        //set this to 0 if u dont want collison of poop
        //poop.physicsBody?.collisionBitMask = topBiteCategory | botBiteCategory
        poop?.physicsBody?.collisionBitMask = 0
        poop?.lightingBitMask = 1
        poop?.shadowCastBitMask = 0
        poop?.shadowedBitMask = 1
        let rightYmax = (troll?.size.height)! / 2 //- poop.size.height
        let rightYmin = (troll?.size.width)! + (poop?.size.height)!
        if right == true {
            //animation
            poop?.run(SKAction.repeatForever(jellyAnimation))
            //unint 32 has to be unsigned otherwise error
            let poopY = rightYmin  + CGFloat(arc4random_uniform(UInt32(rightYmax - rightYmin)))
            if tutorial == true {
                poop?.position = CGPoint(x: (size.width / 2) + (poop?.size.width)!, y: poopY)
                let moveToLeft = SKAction.moveBy(x: -(size.width / 3.2), y: 0, duration: 1.5)
                poop?.run(moveToLeft)
            } else {
                poop?.position = CGPoint(x: (size.width / 2) + ((poop?.size.width)! / 2), y: poopY)
                let moveToLeft = SKAction.moveBy(x: -size.width, y: 0, duration: 3)
                poop?.run(SKAction.sequence([moveToLeft, SKAction.removeFromParent()]))
                //print(size.width/3) velocity is 455
            }

        } else {
            poop?.run(SKAction.repeatForever(jellyAnimation))
            poop?.zRotation = CGFloat.pi
            //unint 32 has to be unsigned otherwise error
            let poopY = -rightYmin - CGFloat(arc4random_uniform(UInt32(rightYmax - rightYmin)))
            poop?.position = CGPoint(x: (-size.width / 2) - ((poop?.size.width)! / 2), y: poopY)
            if tutorial == true {
                let pause = SKAction.wait(forDuration: 3.3)
                //let moveToRight = SKAction.moveTo(x: -(size.width / 2) + size.width / 6.5, duration: 1)
                let moveToRight = SKAction.moveBy(x: size.width, y: 0, duration: 3)
                poop?.run(SKAction.sequence([pause, moveToRight, SKAction.removeFromParent()]))
            } else {
                let moveToRight = SKAction.moveBy(x: size.width, y: 0, duration: 3)
                poop?.run(SKAction.sequence([moveToRight, SKAction.removeFromParent()]))
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false {
            //have to set boundingrectangle in gamescene to enable contact , need physcialBody of both parties!
            if contact.bodyA.node?.name == "leftContact" || contact.bodyB.node?.name == "leftContact" || contact.bodyA.node?.name == "rightContact" || contact.bodyB.node?.name == "rightContact" {
                score += points
                playSound(soundURL: dingSound!)
                scoreBoard?.text = String(score)
            } //when game over triggers
            else if contact.bodyA.node?.name == "poop" && contact.bodyB.node?.name == "troll" || contact.bodyA.node?.name == "troll" && contact.bodyB.node?.name == "poop" {
                
                gameIsOver(bitten : false)


            }
            else if contact.bodyA.node?.name == "midContact" && contact.bodyB.node?.name == "topBite" || contact.bodyA.node?.name == "topBite" && contact.bodyB.node?.name == "midContact"{
                gameIsOver(bitten: true)
            }
    
        }

    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "rightContact" || contact.bodyB.node?.name == "rightContact" {
            lightEnable(enable: true)
        }
    }
    
    func gameIsOver(bitten : Bool) {
        if score > best {
            best = score
            defaults.set(best, forKey: "best")
        }
        //calculate rank here
        var rank : Int = 103 - score
        if score < 4 {
            rank = 99
        } else if score > 102 {
            rank = 1
        }
        bestScore?.text = String(best)
        thisScore?.text = String(score)
        rankScore?.text = "top \(rank)%"
        let revealBoard = SKAction.fadeIn(withDuration: 1.5)
        gameBoard?.run(revealBoard)
        
        //self.speed = 0
        poop?.speed = 0
        troll?.physicsBody?.applyAngularImpulse(2.5)
        //troll?.physicsBody?.angularVelocity = 0
        //invalidates timer
        poopTimer?.invalidate()
        poopDelay?.invalidate()
        
        //run lgihting animation
        if bitten == false {
            playSound(soundURL: buzzSound!)
            diverTexture?.run(strike)
        } else {
            //playSound(soundURL: biteSound!)
            playSound(soundURL: biteSound2!)
        }
        
        //make jellyfish visible by light
        poop?.lightingBitMask = 0
        poop?.shadowCastBitMask = 0
        poop?.shadowedBitMask = 0
        
        //markGame is over
        gameOver = true
        //view?.isUserInteractionEnabled = false
        if score > best {
            best = score
            defaults.set(best, forKey: "best")
        }
                
        //view?.isUserInteractionEnabled = true
        bestScore?.alpha = 1
        thisScore?.alpha = 1
        rankScore?.alpha = 1
        ring?.texture = ringsArray[rank/20]
        ring?.zPosition = 4
        ring?.alpha = 1
        //enable button so user can restart game
        //restartButton?.isUserInteractionEnabled = true
    }
    
    //player taps
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 0 is in game tap, 1 is the last tap to get out tutortial 2 is after tap restart, 3,4 is tutorial
        if gameOver == false {
            if tutorial == true {
                troll?.run(rotateCounterClock!)
                playSound(soundURL: diverSound!)
                troll?.physicsBody?.applyAngularImpulse(-2.5)
                poop?.run(SKAction.sequence([SKAction.moveBy(x: -size.width, y: 0, duration: 3), SKAction.removeFromParent()]))
                beginCreateJelly()
                tutorial = false
                points = 1
                tapIcon?.removeFromParent()
                tapText?.removeFromParent()
            } else {
                troll?.run(rotateCounterClock!)
                playSound(soundURL: diverSound!)
                if (lightBox?.intersects(poop!))! {
                    points = 1
                }
            }
//            if tutorStage == 0 {
//                troll?.run(rotateCounterClock!)
//                playSound(soundURL: diverSound!)
//                if (lightBox?.intersects(poop!))! {
//                    points = 1
//                }
//            } else if tutorStage == 1 {
//                tapText?.removeFromParent()
//                troll?.run(rotateCounterClock!)
//                playSound(soundURL: diverSound!)
//                troll?.physicsBody?.applyAngularImpulse(-2.5)
//                poop?.run(SKAction.sequence([SKAction.moveBy(x: size.width, y: 0, duration: 3), SKAction.removeFromParent()]))
//                beginCreateJelly()
//                tutorStage = 0
//
//            } else if tutorStage == 2 {
//                troll?.run(rotateCounterClock!)
//                playSound(soundURL: diverSound!)
//                troll?.physicsBody?.applyAngularImpulse(-2.5)
//                poop?.run(SKAction.sequence([SKAction.moveBy(x: -size.width, y: 0, duration: 3), SKAction.removeFromParent()]))
//                beginCreateJelly()
//                tutorStage = 0
//                points = 1
//            } else if tutorStage == 3 {
//                tutorStage = 4
//                tapText?.fontColor = UIColor(red: 1, green: 50/255, blue: 139/255, alpha: 1)
//                tapText?.text = "one side is covered in dark, tap to rotate to light this side up"
//                tapText?.fontSize = 72
//                tapIcon?.removeFromParent()
//            } else {
//                troll?.physicsBody?.angularVelocity = -0.4
//                troll?.run(rotateCounterClock!)
//                playSound(soundURL: diverSound!)
//                //print(troll?.physicsBody?.angularVelocity)
//                print("onemoretap false")
//                print("\(troll?.zRotation), \(CGFloat.pi)")
//                if (troll?.zRotation)! >= 2.1{
//                    print("greater than pi")
//                    troll?.physicsBody?.angularVelocity = 0
//                    troll?.zRotation = 2.1
//                    tapText?.fontColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//                    tapText?.text = "dodge jellyfish and don't get bit by shark, tap to start"
//                    tutorStage = 1
//                    points = 1
//                }
//            }
        } else {
            print("gameover Touch")
            if let touch = touches.first {
                let location = touch.location(in: self)
                if (restartButton?.contains(location))! {
                    restart()
                }
                else {
                    print("dont contain")
                }
            }
        }
//            if needTutor == false {
//            } else if needTutor == true && oneMoreTap == true {
//                troll?.run(rotateCounterClock!)
//                playSound(soundURL: diverSound!)
//                //troll?.physicsBody?.angularVelocity = -0.4
//                troll?.physicsBody?.applyAngularImpulse(-2)
//                poop?.run(SKAction.sequence([SKAction.moveBy(x: size.width, y: 0, duration: 3), SKAction.removeFromParent()]))
//                beginCreateJelly()
//                needTutor = false
//                tapIcon?.removeFromParent()
//                tapText?.removeFromParent()

//            } else if needTutor == true && oneMoreTap == false {
//            }
//        } else { //game is over
//            gameOver = false
//            score = 0
//            scoreBoard?.text = String(score)
//            troll?.zRotation = 0
//            //diverTexture?.texture = diverTexture1
//            topBite?.position.y = 383.169
//            botBite?.position.y = -383.169
//            poop?.removeFromParent()
//            //gameBoard?.run(SKAction.moveTo(y: (troll?.position.y)! + size.height, duration: 1))
//            createAJelly(right: true, tutorial: true)
//            tapped = false
        
    }
    
    
    func restart() {
        gameBoard?.removeAllActions()
        gameOver = false
        score = 0
        scoreBoard?.text = String(score)
        troll?.zRotation = 0
        troll?.physicsBody?.angularVelocity = 0
        //diverTexture?.texture = diverTexture1
        topBite?.position.y = 383.169
        botBite?.position.y = -383.169
        poop?.removeFromParent()
        opacityZero()
        //gameBoard?.run(SKAction.moveTo(y: (troll?.position.y)! + size.height, duration: 1))
        createAJelly(right: true, tutorial: true)
        tutorial = true
        lightEnable(enable: false)
        print("restarted")
        //restartButton?.isUserInteractionEnabled = false
    }
    
    func playSound(soundURL : URL)
    {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        }
        catch {
            print(error)
        }
        
        audioPlayer.play()
    }
    
    
    
    
    
    
    
}