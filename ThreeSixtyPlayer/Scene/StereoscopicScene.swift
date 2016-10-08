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

typealias StereoscopicSceneConfiguration = (resolution: CGSize, layout: StereoscopicLayout)

class StereoscopicScene: SCNScene
{
    enum CategoryMask: Int
    {
        case left = 0b1
        case right = 0b10
    }
    
    /// The SpriteKit scene that contains the left video node.
    private let leftVideoScene: VideoScene

    /// The SpriteKit scene that contains the right video node.
    private let rightVideoScene: VideoScene

    /// The camera node used to view the inside of the left sphere.
    let leftCameraNode: SCNNode
    
    /// The camera node used to view the inside of the right sphere.
    let rightCameraNode: SCNNode
    
    // TODO: is initial value of .zero and nil ok? Need a better way to capture the idea of initializing a player without a video.
    init(player: AVPlayer, initialConfiguration: StereoscopicSceneConfiguration? = nil)
    {
        if let configuration = initialConfiguration
        {
            let resolution = configuration.resolution
            let layout = configuration.layout
            
            let leftConfiguration = VideoSceneConfiguration(resolution: resolution, mapping: layout.leftEyeMapping)
            let rightConfiguration = VideoSceneConfiguration(resolution: resolution, mapping: layout.rightEyeMapping)
            
            self.leftVideoScene = VideoScene(player: player, initialConfiguration: leftConfiguration)
            self.rightVideoScene = VideoScene(player: player, initialConfiguration: rightConfiguration)
        }
        else
        {
            self.leftVideoScene = VideoScene(player: player)
            self.rightVideoScene = VideoScene(player: player)
        }
        
        self.leftCameraNode = SCNNode.cameraNode(withCategoryMask: CategoryMask.left.rawValue)
        self.rightCameraNode = SCNNode.cameraNode(withCategoryMask: CategoryMask.right.rawValue)
        
        super.init()
        
        let leftSphereNode = SCNNode.sphereNode(skScene: self.leftVideoScene, categoryMask: CategoryMask.left.rawValue)
        let rightSphereNode = SCNNode.sphereNode(skScene: self.rightVideoScene, categoryMask: CategoryMask.right.rawValue)
        
        self.rootNode.addChildNode(leftSphereNode)
        self.rootNode.addChildNode(rightSphereNode)
        
        self.rootNode.addChildNode(self.leftCameraNode)
        self.rootNode.addChildNode(self.rightCameraNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: Document when/why this method would be called.
    func updateConfiguration(_ configuration: StereoscopicSceneConfiguration)
    {
        let resolution = configuration.resolution
        let layout = configuration.layout

        let leftConfiguration = VideoSceneConfiguration(resolution: resolution, mapping: layout.leftEyeMapping)
        let rightConfiguration = VideoSceneConfiguration(resolution: resolution, mapping: layout.rightEyeMapping)

        self.leftVideoScene.updateConfiguration(leftConfiguration)
        self.rightVideoScene.updateConfiguration(rightConfiguration)
    }
}

