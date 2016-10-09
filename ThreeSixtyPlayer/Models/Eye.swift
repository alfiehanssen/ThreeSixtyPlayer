//
//  Eye.swift
//  ThreeSixtyPlayer
//
//  Created by Alfred Hanssen on 10/9/16.
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

import Foundation
import SceneKit
import AVFoundation

class Eye
{
    let videoTexture: VideoTexture
    let cameraNode: SCNNode
    let sphereNode: SCNNode
    
    init(videoTexture: VideoTexture, categoryBitMask mask: Int? = nil)
    {
        self.videoTexture = videoTexture
        self.cameraNode = SCNNode.cameraNode()
        self.sphereNode = SCNNode.sphereNode(skScene: self.videoTexture.scene)
        
        if let mask = mask
        {
            self.applyCategoryBitMask(mask)
        }
    }
    
    private func applyCategoryBitMask(_ mask: Int)
    {
        self.sphereNode.categoryBitMask = mask
        self.cameraNode.categoryBitMask = mask
        self.cameraNode.camera?.categoryBitMask = mask
    }
}

