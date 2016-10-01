//
//  ThreeSixtyNavigator.swift
//  360Player
//
//  Created by Alfred Hanssen on 9/24/16.
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
import UIKit
import CoreMotion
import SceneKit

class ThreeSixtyNavigator
{
    /// The amount of rotation in radians that can be applied by a single pan gesture.
    private static let MaxPanGestureRotation: Float = GLKMathDegreesToRadians(360)

    /// An enum whose cases describe how a user can manipulate the camera to navigate around the video.
    enum NavigationMode
    {
        /// No navigation
        case None
        
        /// Navigation via UIPanGestureRecognizer.
        case PanGesture
        
        /// Navigation via CMDeviceMotion.
        case DeviceMotion
        
        /// Navigation via UIPanGestureRecognizer and CMDeviceMotion.
        case PanGestureAndDeviceMotion // TODO: Implement this case...
    }
    
    let panGestureController = PanGestureController() // TODO: Can we make this private?
    
    private let deviceMotionController = DeviceMotionController()

    /// The mode by which the user navigates around the video sphere.
    var navigationMode: NavigationMode = .None
    {
        didSet
        {
            switch self.navigationMode
            {
            case .None:
                self.panGestureController.enabled = false
                self.deviceMotionController.enabled = false
                
            case .PanGesture:
                self.deviceMotionController.enabled = false
                self.panGestureController.enabled = true
                
            case .DeviceMotion:
                self.panGestureController.enabled = false
                self.deviceMotionController.enabled = true
                
            case .PanGestureAndDeviceMotion:
                self.panGestureController.enabled = true
                self.deviceMotionController.enabled = true
            }
        }
    }
    
    func currentOrientation(node: SCNNode) -> SCNQuaternion?
    {
        switch self.navigationMode
        {
        case .None:
            return nil
            
        case .PanGesture:
            guard let translationDelta = self.panGestureController.currentPanTranslationDelta else
            {
                return nil
            }
            
            guard let view = self.panGestureController.panGestureRecognizer.view else
            {
                return nil
            }
            
            // Use the pan translation along the x axis to adjust the camera's rotation about the y axis (side to side navigation).
            let yScalar = Float(translationDelta.x / view.bounds.size.width)
            let yRadians = yScalar * type(of: self).MaxPanGestureRotation
            
            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis (up and down navigation).
            let xScalar = Float(translationDelta.y / view.bounds.size.height)
            let xRadians = xScalar * type(of: self).MaxPanGestureRotation
            
            // Represent the node's orientation as a GLKQuaternion
            let scnQuaternion: SCNQuaternion = node.orientation
            var glQuaternion = GLKQuaternionMake(scnQuaternion.x, scnQuaternion.y, scnQuaternion.z, scnQuaternion.w)
            
            // Perform up and down rotations around *CAMERA* X axis (note the order of multiplication)
            let xMultiplier = GLKQuaternionMakeWithAngleAndAxis(xRadians, 1, 0, 0)
            glQuaternion = GLKQuaternionMultiply(glQuaternion, xMultiplier)
            
            // Perform side to side rotations around *WORLD* Y axis (note the order of multiplication, different from above)
            let yMultiplier = GLKQuaternionMakeWithAngleAndAxis(yRadians, 0, 1, 0)
            glQuaternion = GLKQuaternionMultiply(yMultiplier, glQuaternion)
            
            return SCNQuaternion(x: glQuaternion.x, y: glQuaternion.y, z: glQuaternion.z, w: glQuaternion.w)
            
        case .DeviceMotion:
            guard let deviceMotion = self.deviceMotionController.currentDeviceMotion else
            {
                return nil
            }

            return deviceMotion.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
        
        case .PanGestureAndDeviceMotion: // TODO: Add pan gesture to this calculation
            guard let deviceMotion = self.deviceMotionController.currentDeviceMotion else
            {
                return nil
            }
            
            return deviceMotion.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
        }
    }
}

