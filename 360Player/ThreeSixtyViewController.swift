//
//  ViewController.swift
//  360Player
//
//  Created by Alfred Hanssen on 7/5/16.
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

import UIKit
import SceneKit
import SpriteKit
import AVFoundation
import CoreMotion

class ThreeSixtyViewController: UIViewController, SCNSceneRendererDelegate
{
    /// The scene that contains the camera and sphere geometry (with player).
    private let scene = ThreeSixtyScene()
    
    /// The navigator that manages a pan gesture and device motion.
    private let navigator = ThreeSixtyNavigator()
    
    /// The video player.
    var player: AVPlayer
    {
        return self.scene.player
    }
    
    // MARK: Lifecycle
    
    override func loadView()
    {
        let sceneView = SCNView()
        sceneView.scene = self.scene
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.black
        sceneView.delegate = self
        sceneView.pointOfView = self.scene.cameraNode

        self.view = sceneView
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
                
        self.view.addGestureRecognizer(self.navigator.panGestureController.panGestureRecognizer)
        
        // Navigation mode is initially .None.
        self.navigator.navigationMode = .PanGesture
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.startPlayback()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.stopPlayback()
    }
    
    // MARK: Setup
        
    private func startPlayback()
    {
        guard let sceneView = self.view as? SCNView else
        {
            assertionFailure("Attempt to cast self.view as SCNView failed.")
            
            return
        }
        
        sceneView.play(nil)
        self.scene.player.play()
    }

    private func stopPlayback()
    {
        guard let sceneView = self.view as? SCNView else
        {
            assertionFailure("Attempt to cast self.view as SCNView failed.")
            
            return
        }
        
        sceneView.stop(nil)
        self.scene.player.pause()
    }

    // MARK: SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        DispatchQueue.main.async { [weak self] () -> Void in
            guard let strongSelf = self else
            {
                return
            }

            guard let orientation = strongSelf.navigator.currentOrientation(node: strongSelf.scene.cameraNode) else
            {
                return
            }

            strongSelf.scene.cameraNode.orientation = orientation
        }
    }
}

