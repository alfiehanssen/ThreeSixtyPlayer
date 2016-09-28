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
            
            // Use the pan translation along the x axis to adjust the camera's rotation about the y axis.
            let yScalar = Float(translationDelta.x / view.bounds.size.width)
            let yRadians = yScalar * type(of: self).MaxPanGestureRotation
            
            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis.
            let xScalar = Float(translationDelta.y / view.bounds.size.height)
            let xRadians = xScalar * type(of: self).MaxPanGestureRotation
            
            //node.eulerAngles.x += xRadians
            //node.eulerAngles.y += yRadians
            
            
            // We want to rotate the camera about the world x and y axes (as opposed to the camera node's x and y axes)
            // If we simply do the latter, the camera will eventually rotate in unexpected ways.
            
            //spin the camera according the the user's swipes
            
            //get the current rotation of the camera as a quaternion
            //let oldRot: SCNQuaternion = node.rotation;
            
            //make a GLKQuaternion from the SCNQuaternion
            //var rot = GLKQuaternionMakeWithAngleAndAxis(oldRot.w, oldRot.x, oldRot.y, oldRot.z);
            
            //The next function calls take these parameters: rotationAngle, xVector, yVector, zVector
            //The angle is the size of the rotation (radians) and the vectors define the axis of rotation
            
            //For rotation when swiping with X we want to rotate *around* y axis, so if our vector is 0,1,0 that will be the y axis
            //let rotX = GLKQuaternionMakeWithAngleAndAxis(yRadians, 0, 1, 0)
            
            //For rotation by swiping with Y we want to rotate *around* the x axis.  By the same logic, we use 1,0,0
            //let rotY = GLKQuaternionMakeWithAngleAndAxis(xRadians, 1, 0, 0)
            
            //To combine rotations, you multiply the quaternions.  Here we are combining the x and y rotations
            //let netRot = GLKQuaternionMultiply(rotX, rotY)
            
            //finally, we take the current rotation of the camera and rotate it by the new modified rotation.
            //rot = GLKQuaternionMultiply(rot, netRot);

            //Then we have to separate the GLKQuaternion into components we can feed back into SceneKit
            //let axis = GLKQuaternionAxis(rot);
            //let angle = GLKQuaternionAngle(rot);
            
            //finally we replace the current rotation of the camera with the updated rotation
            //node.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle);
            
            
            
            let oldRot: SCNQuaternion = node.orientation;
            let oldRotQ: GLKQuaternion = GLKQuaternionMake(oldRot.x, oldRot.y, oldRot.z, oldRot.w)
            //var _rotMatrix = GLKMatrix4MakeRotation(oldRot.w, oldRot.x, oldRot.y, oldRot.z)
            
            var rotationMatrix = GLKMatrix4MakeWithQuaternion(oldRotQ)
            
            //var isInvertible = false

            //var invertedRotMatrix = GLKMatrix4Invert(rotationMatrix, &isInvertible)
            var xWorldAxis = GLKVector3Make(1, 0, 0)
            //var xObjectAxis = GLKMatrix4MultiplyVector3(invertedRotMatrix, xWorldAxis);
            rotationMatrix = GLKMatrix4Rotate(rotationMatrix, xRadians, xWorldAxis.x, xWorldAxis.y, xWorldAxis.z);
            
            //invertedRotMatrix = GLKMatrix4Invert(rotationMatrix, &isInvertible)
            //let yWorldAxis = GLKVector3Make(0, 1, 0)
            //let yObjectAxis = GLKMatrix4MultiplyVector3(invertedRotMatrix, yWorldAxis);
            //oldRotMatrix = GLKMatrix4Rotate(rotationMatrix, yRadians, yObjectAxis.x, yObjectAxis.y, yObjectAxis.z)
            
            let q = GLKQuaternionMakeWithMatrix4(rotationMatrix)
            let ax = GLKQuaternionAxis(q)
            let an = GLKQuaternionAngle(q)
            
            node.orientation = SCNVector4Make(ax.x, ax.y, ax.z, an) as SCNQuaternion
            
            return nil//node.orientation // TODO: fix this, should return an orientation instead of updating the node directly.
            
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

