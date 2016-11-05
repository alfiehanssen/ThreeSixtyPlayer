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
    let leftEye: Eye
    let rightEye: Eye
    
    convenience init(player: AVPlayer, resolution: CGSize, layout: StereoscopicLayout)
    {
        let leftVideoTexture = VideoTexture(player: player, resolution: resolution, mapping: layout.leftEyeMapping)
        let rightVideoTexture = VideoTexture(player: player, resolution: resolution, mapping: layout.rightEyeMapping)
        
        self.init(leftVideoTexture: leftVideoTexture, rightVideoTexture: rightVideoTexture)
    }
    
    convenience init(player: AVPlayer)
    {
        let leftVideoTexture = VideoTexture(player: player)
        let rightVideoTexture = VideoTexture(player: player)
        
        self.init(leftVideoTexture: leftVideoTexture, rightVideoTexture: rightVideoTexture)
    }
    
    fileprivate init(leftVideoTexture: VideoTexture, rightVideoTexture: VideoTexture)
    {
        self.leftEye = Eye(videoTexture: leftVideoTexture, categoryBitMask: EyeMask.left.rawValue)
        self.rightEye = Eye(videoTexture: rightVideoTexture, categoryBitMask: EyeMask.right.rawValue)
        
        super.init()
        
        self.rootNode.addChildNode(self.leftEye.sphereNode)
        self.rootNode.addChildNode(self.leftEye.cameraNode)
        
        self.rootNode.addChildNode(self.rightEye.sphereNode)
        self.rootNode.addChildNode(self.rightEye.cameraNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(resolution: CGSize, layout: StereoscopicLayout)
    {
        self.leftEye.videoTexture.update(resolution: resolution, mapping: layout.leftEyeMapping)
        self.rightEye.videoTexture.update(resolution: resolution, mapping: layout.rightEyeMapping)
    }
}

