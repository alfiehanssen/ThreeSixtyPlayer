//
//  VideoScene.swift
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

import SpriteKit
import AVFoundation

class VideoScene: SKScene
{
    /// The SpriteKit node that displays the video.
    private let skVideoNode: SKVideoNode
    
    init(player: AVPlayer, initialVideoResolution: CGSize = .zero)
    {
        self.skVideoNode = SKVideoNode(avPlayer: player)
        self.skVideoNode.yScale = -1 // Flip the video so it appears right side up
        
        super.init(size: initialVideoResolution)
        
        self.scaleMode = .aspectFit
        self.addChild(self.skVideoNode)
        
        self.updateVideoResolution(resolution: initialVideoResolution)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateVideoResolution(resolution: CGSize)
    {
        // TODO: Does this method account for screen scale? [AH] 7/7/2016
        
        let rect = CGRect(origin: .zero, size: resolution)
        let position = CGPoint(x: rect.midX, y: rect.midY)
        
        self.skVideoNode.position = position
        self.skVideoNode.size = resolution
        
        self.size = resolution
    }
}

