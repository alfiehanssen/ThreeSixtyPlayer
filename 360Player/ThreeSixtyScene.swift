//
//  ThreeSixtyScene.swift
//  360Player
//
//  Created by Alfred Hanssen on 9/14/16.
//  Copyright © 2016 Alfie Hanssen. All rights reserved.
//

import SceneKit
import SpriteKit
import AVFoundation

class ThreeSixtyScene: SCNScene
{
    /// The radius of the sphere on which we project the video texture.
    fileprivate static let SphereRadius: CGFloat = 100 // TODO: How to choose the sphere radius? [AH] 7/7/2016
    
    /// The camera node used to view the inside of the sphere (video).
    let cameraNode: SCNNode
    
    /// The video player that is projected onto the spehere.
    let player: AVPlayer
    
    required init(player: AVPlayer, videoSize: CGSize) // TODO: Do not pass in size, observe changes to currentItem?
    {
        self.player = player
        
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Zero
        self.cameraNode = cameraNode
                
        let videoNode = SKVideoNode(avPlayer: player)
        videoNode.position = CGPoint(x: videoSize.width / 2, y: videoSize.height / 2)
        videoNode.size = videoSize
        videoNode.yScale = -1 // Flip the video so it appears right side up
        
        let skScene = SKScene()
        skScene.size = videoSize
        skScene.scaleMode = .aspectFit
        skScene.addChild(videoNode)
        
        let material = SCNMaterial()
        material.diffuse.contents = skScene
        material.cullMode = .front // Ensure that the material renders on the inside of our sphere
        
        let sphere = SCNSphere()
        sphere.radius = type(of: self).SphereRadius
        sphere.firstMaterial = material
        
        let geometryNode = SCNNode()
        geometryNode.geometry = sphere
        geometryNode.position = SCNVector3Zero
        
        super.init()
        
        self.rootNode.addChildNode(geometryNode)
        self.rootNode.addChildNode(cameraNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

