//
//  GameScene.swift
//  PandaClicker Shared
//
//  Created by Irem Karaoglu on 25.09.2021.
//

import SpriteKit

class GameScene: SKScene {
    
    
    fileprivate var countLabel : SKLabelNode?
    fileprivate var panda : SKSpriteNode?
    let screenSize: CGRect = UIScreen.main.bounds
    var screenWidth:CGFloat {return screenSize.width}
    var screenHeight:CGFloat {return screenSize.height}
    var counter: Int = 0

    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        let countLabel = SKLabelNode()
        countLabel.text = String(counter)
        countLabel.fontSize = 72
        countLabel.position = CGPoint(x: screenWidth / 2, y:screenHeight - 150 )
        countLabel.color = .white
        self.countLabel = countLabel
        self.addChild(countLabel)
        let panda = SKSpriteNode(imageNamed: "panda")
        panda.scale(to: CGSize(width: 300, height: 300))
        panda.name = "panda"
        panda.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        panda.position = CGPoint(x: screenWidth / 2, y:screenHeight / 2)
        self.panda = panda
        self.addChild(panda)
        
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        self.setUpScene()
    }
    #endif
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.countLabel {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        if let location = touches.first?.location(in: self) {
            for node in self.nodes(at: location){
                if node.name == "panda" {
                    runHaptics()
                    node.run(SKAction.playSoundFileNamed("panda_tap.mp3", waitForCompletion: true))
                    getSmallPanda()
                    counter += 1
                    countLabel?.text = String(counter)
                    self.panda?.scale(to: CGSize(width: 280, height: 280))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.panda?.scale(to: CGSize(width: 300, height: 300))
                    }
                    
                    
                    if (counter.isMultiple(of: 10)) {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        if let myEmitter =  SKEmitterNode(fileNamed: "MagicParticle.sks") {
                            myEmitter.particleScale = 0.3
                            myEmitter.position = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
                            myEmitter.particleZPosition = 1
                            addChild(myEmitter)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            myEmitter.particleBirthRate = 0
                            }
                        }
                    }
                    
                    return
                }
            }
        }
        
    }
    func newSmokeEmitter() -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: "MagicParticle.sks")
    }
    
    func getSmallPanda() {
        let panda = SKSpriteNode(imageNamed: "panda")
        panda.name = "panda"
        panda.scale(to: CGSize(width: 100, height: 100))
        panda.zPosition = 1
        panda.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let randomXPos = CGFloat.random(in: 0..<screenWidth)
        panda.position = CGPoint(x: randomXPos, y: screenHeight)
        panda.run(.sequence([
            .moveTo(y: -72, duration: 0.80),
            .removeFromParent()
        ]))
        self.addChild(panda)
    }
    
    func runHaptics() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
    }

}
#endif
