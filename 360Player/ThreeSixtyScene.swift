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
    
    /// The default size of the SKVideoNode and SKScene, updated when the player's item updates.
    private static let DefaultVideoResolution = CGSize(width: 1920, height: 1080)

    private static let PlayerCurrentItemKeyPath = "currentItem"

    private var playerCurrentItemKVOContext = 0

    private let videoNode: SKVideoNode
    
    private let spriteKitScene: SKScene
    
    /// The camera node used to view the inside of the sphere (video).
    let cameraNode: SCNNode
    
    /// The video player that is projected onto the spehere.
    var player = AVPlayer()
    
    deinit
    {
        self.removePlayerItemObserver()
    }
    
    override init()
    {
        self.videoNode = SKVideoNode(avPlayer: self.player)
        self.videoNode.yScale = -1 // Flip the video so it appears right side up
        
        self.spriteKitScene = SKScene()
        self.spriteKitScene.scaleMode = .aspectFit
        self.spriteKitScene.addChild(self.videoNode)

        self.cameraNode = SCNNode()
        self.cameraNode.position = SCNVector3Zero
        self.cameraNode.pivot = SCNMatrix4Identity
        self.cameraNode.camera = SCNCamera()
        self.cameraNode.camera?.automaticallyAdjustsZRange = true

        super.init()
        
        let material = SCNMaterial()
        material.diffuse.contents = spriteKitScene
        material.cullMode = .front // Ensure that the material renders on the inside of our sphere
        
        let sphere = SCNSphere()
        sphere.radius = type(of: self).SphereRadius
        sphere.firstMaterial = material
        
        let geometryNode = SCNNode()
        geometryNode.geometry = sphere
        geometryNode.position = SCNVector3Zero
        
        self.rootNode.addChildNode(geometryNode)
        self.rootNode.addChildNode(self.cameraNode)
        
        let defaultResolution = type(of: self).DefaultVideoResolution
        self.updateGeometryForVideoResolution(resolution: defaultResolution)

        self.addPlayerItemObserver()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Observers
    
    private func addPlayerItemObserver()
    {
        self.player.addObserver(self, forKeyPath: type(of: self).PlayerCurrentItemKeyPath, options: .new, context: &self.playerCurrentItemKVOContext)
    }
    
    private func removePlayerItemObserver()
    {
        self.player.removeObserver(self, forKeyPath: type(of: self).PlayerCurrentItemKeyPath, context: &self.playerCurrentItemKVOContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == type(of: self).PlayerCurrentItemKeyPath
            && context == &self.playerCurrentItemKVOContext
        {
            guard let playerItem = change?[.newKey] as? AVPlayerItem else
            {
                return
            }

            self.updateGeometryForPlayerItem(playerItem: playerItem)
        }
        else
        {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func updateGeometryForPlayerItem(playerItem: AVPlayerItem)
    {
        guard let resolution = playerItem.asset.encodedResolution(),
            resolution != CGSize.zero else
        {
            assertionFailure("Unable to access encoded resolution for video resource.")
            
            return
        }
        
        self.updateGeometryForVideoResolution(resolution: resolution)
    }

    private func updateGeometryForVideoResolution(resolution: CGSize)
    {
        // TODO: Does this account for screen scale? [AH] 7/7/2016
        
        let rect = CGRect(origin: .zero, size: resolution)
        let position = CGPoint(x: rect.midX, y: rect.midY)
        
        self.videoNode.position = position
        self.videoNode.size = resolution
        
        self.spriteKitScene.size = resolution
    }
}

