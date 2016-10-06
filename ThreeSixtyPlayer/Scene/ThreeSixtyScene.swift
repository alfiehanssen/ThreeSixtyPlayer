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

    /// The camera node used to view the inside of the sphere (video).
    let cameraNode: SCNNode

    init(player: AVPlayer)
    {
        self.cameraNode = type(of: self).makeCameraNode()
        
        super.init()

        let geometryNode = type(of: self).makeGeometryNode(withPlayer: player)
        self.rootNode.addChildNode(geometryNode)
    
        self.rootNode.addChildNode(self.cameraNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func makeCameraNode() -> SCNNode
    {
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        //camera.categoryBitMask = categoryMask.rawValue
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        //cameraNode.categoryBitMask = categoryMask.rawValue
        
        return cameraNode
    }
    
    private static func makeGeometryNode(withPlayer player: AVPlayer) -> SCNNode
    {
        let videoScene = VideoScene(player: player)
        
        let material = SCNMaterial()
        material.diffuse.contents = videoScene
        material.cullMode = .front // Ensure that the material renders on the inside of our sphere
        
        let sphere = SCNSphere()
        sphere.radius = ThreeSixtyScene.SphereRadius
        sphere.firstMaterial = material
        
        let geometryNode = SCNNode()
        geometryNode.geometry = sphere
        geometryNode.position = SCNVector3Zero
        //geometryNode.categoryBitMask = categoryMask.rawValue

        return geometryNode
    }
}

