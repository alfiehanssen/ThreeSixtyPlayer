//
//  VideoScene.swift
//  ThreeSixtyPlayer
//
//  Created by Alfred Hanssen on 10/5/16.
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

enum VideoViewPort
{
    case monoscopic
    case stereoscopic(quadrant)
    
    enum quadrant
    {
        case top
        case bottom
        case left
        case right
    }
    
    var anchorPoint: CGPoint
    {
        switch self
        {
        case .monoscopic:
            return CGPoint(x: 0.5, y: 0.5)
            
        case .stereoscopic(let quadrant):
            switch quadrant
            {
            case .top:
                return CGPoint(x: 0.5, y: 0.5)

            case .bottom:
                return CGPoint(x: 0.5, y: 0.5)
                
            case .left:
                return CGPoint(x: 0.5, y: 0.5)
                
            case .right:
                return CGPoint(x: 0.5, y: 0.5)
            }
        }
    }
}

class VideoScene: SKScene
{
    /// The default size of the SKVideoNode and SKScene, updated when the player's item updates.
    private static let DefaultVideoResolution = CGSize(width: 1920, height: 1080)
    
    /// The KVO key path used to observe changes to the player's currentItem.
    private static let PlayerCurrentItemKeyPath = "currentItem"
    
    /// The KVO context used to observe changes to the player's currentItem.
    private var playerCurrentItemKVOContext = 0
    
    /// The SpriteKit node that displays the video.
    private let videoNode: SKVideoNode
    
    /// The video player that is projected onto the spehere.
    private let player: AVPlayer
    
    private let videoViewPort: VideoViewPort
    
    deinit
    {
        self.removePlayerItemObserver()
    }
    
    init(player: AVPlayer, videoViewPort: VideoViewPort)
    {
        self.player = player
        
        self.videoNode = SKVideoNode(avPlayer: player)
        self.videoNode.yScale = -1 // Flip the video so it appears right side up
        
        super.init(size: .zero)
        
        self.scaleMode = .aspectFit
        self.addChild(self.videoNode)
        
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
    
    // MARK: - Observer Utilities
    
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
    
    /// Changes the scene and video node size and position to match the specified resolution.
    private func updateGeometryForVideoResolution(resolution: CGSize)
    {
        // TODO: Does this account for screen scale? [AH] 7/7/2016
        
        let rect = CGRect(origin: .zero, size: resolution)
        let position = CGPoint(x: rect.midX, y: rect.midY)
        
        self.videoNode.position = position
        self.videoNode.size = resolution

        self.size = resolution
    }
}

