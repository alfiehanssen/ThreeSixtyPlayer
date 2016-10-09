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
    let eye: Eye
    
    convenience init(player: AVPlayer, resolution: CGSize, mapping: TextureMapping = .none)
    {
        let videoTexture = VideoTexture(player: player, resolution: resolution, mapping: mapping)
        
        self.init(videoTexture: videoTexture)
    }
    
    convenience init(player: AVPlayer)
    {
        let videoTexture = VideoTexture(player: player)
    
        self.init(videoTexture: videoTexture)
    }
    
    private init(videoTexture: VideoTexture)
    {
        self.eye = Eye(videoTexture: videoTexture)
        
        super.init()
        
        self.rootNode.addChildNode(self.eye.cameraNode)
        self.rootNode.addChildNode(self.eye.sphereNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(resolution: CGSize, mapping: TextureMapping = .none)
    {
        self.eye.videoTexture.update(resolution: resolution, mapping: mapping)
    }
}

