//
//  MonoscopicScene.swift
//  ThreeSixtyPlayer
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
import AVFoundation

class MonoscopicScene: SCNScene
{
    /// The SpriteKit scene that contains the video node.
    private let videoScene: VideoScene
    
    /// The camera node used to view the inside of the sphere (video).
    let cameraNode: SCNNode
    
    init(player: AVPlayer, initialVideoResolution: CGSize)
    {
        let configuration = VideoSceneConfiguration(resolution: initialVideoResolution, stereoscopicMapping: nil)
        
        self.videoScene = VideoScene(player: player, initialConfiguration: configuration)
        
        self.cameraNode = SCNNode.cameraNode()
        
        super.init()
        
        let sphereNode = SCNNode.sphereNode(skScene: self.videoScene)
        
        self.rootNode.addChildNode(sphereNode)
        self.rootNode.addChildNode(self.cameraNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: Document when/why this method would be called.
    func updateVideoResolution(_ resolution: CGSize)
    {
        let configuration = VideoSceneConfiguration(resolution: resolution, stereoscopicMapping: nil)

        self.videoScene.updateConfiguration(configuration)
    }
}

