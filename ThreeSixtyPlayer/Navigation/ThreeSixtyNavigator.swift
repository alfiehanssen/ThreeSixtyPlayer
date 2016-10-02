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

/// A controller that manages the 360 player's navigation mode and by extension a pan gesture controller and a device motion controller.
class ThreeSixtyNavigator
{
    /// A tuple `typealias` used to hold a pair of rotation offsets about the X and Y axes.  
    private typealias RotationOffset = (x: Float, y: Float)

    /// The amount of rotation in radians that can be applied by a single pan gesture.
    private static let MaxPanGestureRotation: Float = GLKMathDegreesToRadians(360)

    /**
        An enum whose cases describe how a user can manipulate the camera to navigate around the video.
     
        - `None`: The user cannot navigate around the sphere. This is the default value.
        - `PanGesture`: The user can navigate using a pan gesture.
        - `DeviceMotion`: The user can navigate using the device "motion" aka orientation.
        - `PanGestureAndDeviceMotion`: The user can navigate using pan gesture and device motion simultaneously.
     */
    enum NavigationMode
    {
        case None
        case PanGesture
        case DeviceMotion
        case PanGestureAndDeviceMotion
    }
    
    /// The controller used to track the pan gesture's translation delta.
    let panGestureController = PanGestureController() // TODO: Can we make this private?
    
    /// The controller used to track the device motion (orientation).
    private let deviceMotionController = DeviceMotionController()

    /// The cumulative amount of pan gesture translation in the X direction.
    private var cumulativePanOffsetX: Float = 0

    /// The cumulative amount of pan gesture translation in the Y direction.
    private var cumulativePanOffsetY: Float = 0
    
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
    
    /**
        A function that uses the current navigation mode to update the camera's orientation.
     
     - parameter orientation: The orientation that pan gesture and/or device motion modifications should be applied to.
     
     - returns: The modified `orientation` after having applied the appropriate pan gesture and/or device motion rotations.
     */
    func currentOrientation(orientation: SCNQuaternion) -> SCNQuaternion?
    {
        switch self.navigationMode
        {
        case .None:
            return nil

        case .DeviceMotion:
            // Device motion can be nil at times, this is ok.
            guard let deviceMotion = self.deviceMotionController.currentDeviceMotion else
            {
                return nil
            }
            
            return deviceMotion.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
            
        case .PanGesture:
            
            let rotationOffset = self.panGestureRotationOffset()
            let currentOrientation = type(of: self).rotateOrientation(orientation: orientation, byRotationOffset: rotationOffset)
            
            return currentOrientation
            
        case .PanGestureAndDeviceMotion:
            // Device motion can be nil at times, this is ok.
            guard let deviceMotion = self.deviceMotionController.currentDeviceMotion else
            {
                // TODO: Should we fall back on pan gesture here? [AH] 10/1/2016
                
                return nil
            }
            
            let rotationOffset = self.panGestureRotationOffset()

            // Modify the persisted cumulative offsets accordingly.
            self.cumulativePanOffsetX += rotationOffset.x
            self.cumulativePanOffsetY += rotationOffset.y

            let orientation = deviceMotion.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
            let cumulativeOffset = RotationOffset(x: self.cumulativePanOffsetX, y: self.cumulativePanOffsetY)
            let currentOrientation = type(of: self).rotateOrientation(orientation: orientation, byRotationOffset: cumulativeOffset)
            
            return currentOrientation
        }
    }
    
    private func panGestureRotationOffset() -> RotationOffset
    {
        let maxRotation = type(of: self).MaxPanGestureRotation
        let viewBounds = self.panGestureController.viewBounds
        let translationDelta = self.panGestureController.currentPanTranslationDelta

        // TODO: Can we avoid doing this? [AH] 10/1/2016
        // Once we read the delta, set it to nil.
        // If we don't do this, when the user leaves their finger stationary on the screen the most recent delta will be applied every frame.
        // This means the camera will continue to rotate despite the user's finger being stationary.
        self.panGestureController.currentPanTranslationDelta = .zero

        // Use the pan translation along the x axis to adjust the camera's rotation about the y axis (side to side navigation).
        let yScalar = Float(translationDelta.x / viewBounds.size.width)
        let yRadians = yScalar * maxRotation
        
        // Use the pan translation along the y axis to adjust the camera's rotation about the x axis (up and down navigation).
        let xScalar = Float(translationDelta.y / viewBounds.size.height)
        let xRadians = xScalar * maxRotation

        return RotationOffset(x: xRadians, y: yRadians)
    }
    
    private static func rotateOrientation(orientation: SCNQuaternion, byRotationOffset rotationOffset: RotationOffset) -> SCNQuaternion
    {
        // Represent the orientation as a GLKQuaternion
        var glQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
        
        // Perform up and down rotations around *CAMERA* X axis (note the order of multiplication)
        let xMultiplier = GLKQuaternionMakeWithAngleAndAxis(rotationOffset.x, 1, 0, 0)
        glQuaternion = GLKQuaternionMultiply(glQuaternion, xMultiplier)
        
        // Perform side to side rotations around *WORLD* Y axis (note the order of multiplication, different from above)
        let yMultiplier = GLKQuaternionMakeWithAngleAndAxis(rotationOffset.y, 0, 1, 0)
        glQuaternion = GLKQuaternionMultiply(yMultiplier, glQuaternion)
        
        return SCNQuaternion(x: glQuaternion.x, y: glQuaternion.y, z: glQuaternion.z, w: glQuaternion.w)
    }
}

