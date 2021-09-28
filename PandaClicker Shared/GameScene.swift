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
    fileprivate var spinnyNode : SKShapeNode?
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
        panda.position = CGPoint(x: screenWidth / 2, y:screenHeight / 2
        )
        self.addChild(panda)
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            
            #if os(watchOS)
                // For watch we just periodically create one of these and let it spin
                // For other platforms we let user touch/mouse events create these
                spinnyNode.position = CGPoint(x: 0.0, y: 0.0)
                spinnyNode.strokeColor = SKColor.red
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                                                   SKAction.run({
                                                                       let n = spinnyNode.copy() as! SKShapeNode
                                                                       self.addChild(n)
                                                                   })])))
            #endif
        }
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

    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
    
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
        
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
        if let location = touches.first?.location(in: self) {
            for node in self.nodes(at: location){
                if node.name == "panda" {
                    node.run(SKAction.playSoundFileNamed("panda_tap.mp3", waitForCompletion: true))
                    getSmallPanda()
                    counter += 1
                    countLabel?.text = String(counter)
                    return
                }
            }
        }
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
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
        self.makeSpinny(at: event.location(in: self), color: SKColor.green)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.red)
    }

}
#endif

