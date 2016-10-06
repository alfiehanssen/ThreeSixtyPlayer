//
//  StereoscopicScene.swift
//  ThreeSixtyPlayer
//
//  Created by Alfred Hanssen on 10/6/16.
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

class StereoscopicScene: SCNScene
{
    enum CategoryMask: Int
    {
        case left = 0b1
        case right = 0b10
    }
    
    /// The SpriteKit scene that contains the video node.
    private let videoScene: VideoScene
    
    /// The camera node used to view the inside of the left sphere.
    let leftCameraNode: SCNNode
    
    /// The camera node used to view the inside of the right sphere.
    let rightCameraNode: SCNNode
    
    init(player: AVPlayer, initialVideoResolution: CGSize = .zero, initialVideoType: VideoType) // TODO: default value for type?
    {
        self.videoScene = VideoScene(player: player, initialVideoResolution: initialVideoResolution)
        
        self.leftCameraNode = SCNNode.cameraNode(withCategoryMask: CategoryMask.left.rawValue)
        self.rightCameraNode = SCNNode.cameraNode(withCategoryMask: CategoryMask.right.rawValue)
        
        super.init()
        
        let leftSphereNode = SCNNode.sphereNode(skScene: self.videoScene, categoryMask: CategoryMask.left.rawValue)
        let rightSphereNode = SCNNode.sphereNode(skScene: self.videoScene, categoryMask: CategoryMask.right.rawValue)
        
        self.rootNode.addChildNode(leftSphereNode)
        self.rootNode.addChildNode(rightSphereNode)
        
        self.rootNode.addChildNode(self.leftCameraNode)
        self.rootNode.addChildNode(self.rightCameraNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: How to update video type (top/bottom, left/right)?
    func updateVideoResolution(resolution: CGSize)
    {
        self.videoScene.updateVideoResolution(resolution: resolution)
    }
}

