//
//  ThreeSixtyScene.swift
//  360Player
//
//  Created by Alfred Hanssen on 9/14/16.
//  Copyright © 2016 Alfie Hanssen. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SceneKit
import SpriteKit
import AVFoundation

class ThreeSixtyScene: SCNScene
{
    /// The radius of the sphere on which we project the video texture.
    private static let SphereRadius: CGFloat = 100 // TODO: How to choose the sphere radius? [AH] 7/7/2016

//    enum CategoryMask: Int
//    {
//        case left = 0b1
//        case right = 0b10
//    }

    /// The SpriteKit node that displays the video.
    private let skVideoNode: SKVideoNode
    
    /// The SpriteKit scene that contains the video node.
    private let skScene: SKScene

    /// The camera node used to view the inside of the sphere (video).
    let cameraNode: SCNNode

    init(player: AVPlayer, initialVideoMapping: VideoMapping)
    {
        self.skVideoNode = SKVideoNode(avPlayer: player)
        self.skVideoNode.yScale = -1 // Flip the video so it appears right side up

        self.skScene = SKScene(size: .zero) // Initialize to .zero, we update size immediately.
        self.skScene.scaleMode = .aspectFit
        self.skScene.addChild(self.skVideoNode)

        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        //camera.categoryBitMask = categoryMask.rawValue
        
        self.cameraNode = SCNNode()
        self.cameraNode.camera = camera
        //cameraNode.categoryBitMask = categoryMask.rawValue
        
        super.init()

        self.updateVideoMapping(videoMapping: initialVideoMapping)

        let material = SCNMaterial()
        material.diffuse.contents = self.skScene
        material.cullMode = .front // Ensure that the material renders on the inside of our sphere
        
        let sphere = SCNSphere()
        sphere.radius = ThreeSixtyScene.SphereRadius
        sphere.firstMaterial = material
        
        let geometryNode = SCNNode()
        geometryNode.geometry = sphere
        geometryNode.position = SCNVector3Zero
        //geometryNode.categoryBitMask = categoryMask.rawValue

        self.rootNode.addChildNode(geometryNode)
        self.rootNode.addChildNode(self.cameraNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    func updateVideoMapping(videoMapping: VideoMapping)
    {
        // TODO: Does this method account for screen scale? [AH] 7/7/2016
        
        let resolution = videoMapping.resolution
        
        let rect = CGRect(origin: .zero, size: resolution)
        let position = CGPoint(x: rect.midX, y: rect.midY)
        
        self.skVideoNode.position = position
        self.skVideoNode.size = resolution
        
        self.skScene.size = resolution
    }
}

