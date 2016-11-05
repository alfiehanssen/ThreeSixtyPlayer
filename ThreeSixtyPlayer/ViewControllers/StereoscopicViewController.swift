//
//  StereoscopicViewController.swift
//  ThreeSixtyPlayer
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
import AVFoundation

// TODO: Reduce code duplication between the mono and stereo view controllers. 

open class StereoscopicViewController: UIViewController, SCNSceneRendererDelegate
{
    /// The navigator that manages a pan gesture and device motion.
    fileprivate let navigator = ThreeSixtyNavigator()
    
    fileprivate let leftSceneView = SCNView()
    fileprivate let rightSceneView = SCNView()
    
    /// The video player.
    fileprivate let player: AVPlayer

    fileprivate let scene: StereoscopicScene

    open var video: Video?
    {
        didSet
        {
            guard let video = self.video else
            {
                self.player.pause()
                self.player.replaceCurrentItem(with: nil)
                
                return
            }
            
            guard case .stereoscopic(layout: let layout) = video.type else
            {
                fatalError("Attempt to play a monoscopic video as stereoscopic.")
            }
            
            // TODO: Can we link updating scene resolution with replacing the player item?
            self.scene.update(resolution: video.resolution, layout: layout)
            self.player.replaceCurrentItem(with: video.playerItem)
            self.player.play()
        }
    }
    
    public init(player: AVPlayer)
    {
        self.player = player
        self.scene = StereoscopicScene(player: self.player)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle 
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black

        self.setupSceneViews()
        self.setupNavigator()
        self.setupConstraints()
        
        // Invoking play on the sceneView seems to allow it to begin obeying autolayout constraints / autoresizing mask.
        // Without this, sceneView doesn't resize on device rotation.
        self.leftSceneView.play(nil)
        self.rightSceneView.play(nil)
    }
    
    override open func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.player.play()
    }
    
    override open func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.player.pause()
    }
    
    // MARK: - Setup
    
    fileprivate func setupSceneViews()
    {
        self.leftSceneView.showsStatistics = true
        self.leftSceneView.backgroundColor = UIColor.black
        self.leftSceneView.translatesAutoresizingMaskIntoConstraints = false
        self.leftSceneView.delegate = self
        self.leftSceneView.scene = self.scene
        self.leftSceneView.pointOfView = self.scene.leftEye.cameraNode

        self.rightSceneView.showsStatistics = true
        self.rightSceneView.backgroundColor = UIColor.black
        self.rightSceneView.translatesAutoresizingMaskIntoConstraints = false
        self.rightSceneView.delegate = self
        self.rightSceneView.scene = self.scene
        self.rightSceneView.pointOfView = self.scene.rightEye.cameraNode

        self.view.addSubview(self.leftSceneView)
        self.view.addSubview(self.rightSceneView)
    }
    
    fileprivate func setupNavigator()
    {
        // Ensure that navigator's pan gesture is added to our view.
        self.navigator.setupPanGestureRecognizer(withView: self.view)
        
        // Navigation mode is initially .None.
        self.navigator.navigationMode = .panGestureAndDeviceMotion
    }
    
    // MARK: Constraints 
    
    fileprivate func setupConstraints()
    {
        let leftTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.leftSceneView, attribute: .top, multiplier: 1, constant: 0)
        let leftLeadingConstraint = NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: self.leftSceneView, attribute: .leading, multiplier: 1, constant: 0)
        let leftBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.leftSceneView, attribute: .bottom, multiplier: 1, constant: 0)
        
        let middleConstraint = NSLayoutConstraint(item: self.leftSceneView, attribute: .trailing, relatedBy: .equal, toItem: self.rightSceneView, attribute: .leading, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self.leftSceneView, attribute: .width, relatedBy: .equal, toItem: self.rightSceneView, attribute: .width, multiplier: 1, constant: 0)
        
        let rightTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.rightSceneView, attribute: .top, multiplier: 1, constant: 0)
        let rightTrailingConstraint = NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: self.rightSceneView, attribute: .trailing, multiplier: 1, constant: 0)
        let rightBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.rightSceneView, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.view.addConstraint(leftTopConstraint)
        self.view.addConstraint(leftLeadingConstraint)
        self.view.addConstraint(leftBottomConstraint)
        self.view.addConstraint(middleConstraint)
        self.view.addConstraint(widthConstraint)
        self.view.addConstraint(rightTopConstraint)
        self.view.addConstraint(rightTrailingConstraint)
        self.view.addConstraint(rightBottomConstraint)
    }

    // MARK: - SCNSceneRendererDelegate
    
    open func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        // TODO: Necessary to dispatch to main? Implications of doing so? Thread safty of navigator class / pan recognizer is one issue.
        
        DispatchQueue.main.async { [weak self] () -> Void in
            guard let strongSelf = self else
            {
                return
            }

            let orientation = strongSelf.navigator.updateCurrentOrientation()
            
            strongSelf.scene.leftEye.cameraNode.orientation = orientation
            strongSelf.scene.rightEye.cameraNode.orientation = orientation
        }
    }
}

