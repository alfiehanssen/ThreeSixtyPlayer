//
//  VideoTexture.swift
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
import SpriteKit
import AVFoundation

class VideoTexture
{
    /// A SpriteKit node that displays video content managed by the player.
    private let videoNode: SKVideoNode
    
    /// A SpriteKit scene that contains a video node.
    let scene: SKScene
    
    convenience init(player: AVPlayer)
    {
        self.init(player: player, resolution: CGSize.DefaultVideoResolution, mapping: .none)
    }
    
    init(player: AVPlayer, resolution: CGSize, mapping: TextureMapping)
    {
        self.videoNode = SKVideoNode(avPlayer: player)
        self.videoNode.xScale = -1 // Flip the video so it's oriented properly left/right
        self.videoNode.yScale = -1 // Flip the video so it's oriented properly top/bottom

        self.scene = SKScene(size: .zero) // We update this to a non-.zero size immediately (see below).
        self.scene.scaleMode = .aspectFit
        self.scene.addChild(self.videoNode)
        
        self.update(resolution: resolution, mapping: mapping)
    }
    
    func update(resolution: CGSize, mapping: TextureMapping)
    {
        guard resolution.isGreaterThanZero else
        {
            fatalError("Reolution must be greater than .zero in both dimensions.")
        }

        let sceneSize = mapping.sceneSize(videoResolution: resolution)
        
        self.videoNode.anchorPoint = mapping.videoNodeAnchorPoint
        self.videoNode.position = sceneSize.midPoint
        self.videoNode.size = resolution
        self.scene.size = sceneSize
    }
}

