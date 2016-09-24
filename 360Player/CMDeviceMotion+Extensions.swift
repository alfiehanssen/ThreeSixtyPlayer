//
//  CMDeviceMotion+Extensions.swift
//  360Player
//
//  Created by Alfred Hanssen on 7/10/16.
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
import CoreMotion
import SceneKit
import UIKit

// Modified from source: http://stackoverflow.com/questions/31823012/cameranode-rotate-as-ios-device-moving [AH] 7/9/2016

extension CMDeviceMotion
{
    // TODO: Flesh out this documentation further. Explain why we swap and change the signs of x and y when we do. [AH] 7/9/2016
    
    /**
     The CMDeviceMotion and SceneKit coordinate systems' default orientations differ from one another. For both, the gaze of the zero orientation is in the direction of the negative Z axis.
     
     For CMDeviceMotion the "gaze" of the orientation is down at the device screen in the direction of the floor. For SceneKit the "gaze" of the orientation is straight ahead parallel to the floor.
     
     If we want to align the CMDeviceMotion gaze with the SceneKit gaze (e.g. a camera node) we have to rotate the CMDeviceMotion orientation.
     
     - parameter orientation: The UIInterfaceOrientation of the device interface.
     
     - returns: The SCNQuaternion representation of the CMDeviceMotion's attitude quaternion.
     */
    func gaze(atOrientation orientation: UIInterfaceOrientation) -> SCNQuaternion
    {
        let scnQuaternion: SCNQuaternion
        
        let cmQuaternion = self.attitude.quaternion
        let glQuaternion = GLKQuaternionMake(Float(cmQuaternion.x), Float(cmQuaternion.y), Float(cmQuaternion.z), Float(cmQuaternion.w))
        
        switch orientation
        {
        case .landscapeRight:
            let radians = Float(M_PI_2)
            let multiplier = GLKQuaternionMakeWithAngleAndAxis(radians, 0, 1, 0) // Rotate 90 degrees around the Y axis
            let q = GLKQuaternionMultiply(multiplier, glQuaternion)
            
            scnQuaternion = SCNQuaternion(x: -q.y, y: q.x, z: q.z, w: q.w)
            
        case .landscapeLeft:
            let radians = -Float(M_PI_2)
            let multiplier = GLKQuaternionMakeWithAngleAndAxis(radians, 0, 1, 0) // Rotate -90 degrees around the Y axis
            let q = GLKQuaternionMultiply(multiplier, glQuaternion)
            
            scnQuaternion = SCNQuaternion(x: q.y, y: -q.x, z: q.z, w: q.w)
            
        case .portraitUpsideDown:
            let radians = Float(M_PI_2)
            let multiplier = GLKQuaternionMakeWithAngleAndAxis(radians, 1, 0, 0) // Rotate 90 degrees around the X axis
            let q = GLKQuaternionMultiply(multiplier, glQuaternion)
            
            scnQuaternion = SCNQuaternion(x: -q.x, y: -q.y, z: q.z, w: q.w)
            
        case .portrait, .unknown:
            let radians = -Float(M_PI_2)
            let multiplier = GLKQuaternionMakeWithAngleAndAxis(radians, 1, 0, 0) // Rotate -90 degrees around the X axis
            let q = GLKQuaternionMultiply(multiplier, glQuaternion)
            
            scnQuaternion = SCNQuaternion(x: q.x, y: q.y, z: q.z, w: q.w)
        }
        
        return scnQuaternion
    }
}
