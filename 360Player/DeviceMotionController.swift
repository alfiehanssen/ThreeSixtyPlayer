//
//  DeviceMotionController.swift
//  360Player
//
//  Created by Alfred Hanssen on 9/25/16.
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

/// A controller that manages device motion updates.
class DeviceMotionController
{
    /// The interval at which device motion updates will be reported.
    private static let DeviceMotionUpdateInterval: TimeInterval = 1 / 60
    
    /// The motion manager used to adjust camera position based on device motion.
    private let motionManager = CMMotionManager()
    
    /// Accessor for the current device motion.
    var currentDeviceMotion: CMDeviceMotion?
    {
        return self.motionManager.deviceMotion
    }
    
    /// A boolean that starts and stops device motion updates, if device motion is available.
    var enabled = false
    {
        didSet
        {
            guard self.motionManager.isDeviceMotionAvailable else
            {
                return
            }
            
            if self.enabled
            {
                guard !self.motionManager.isDeviceMotionActive else
                {
                    return
                }
                
                self.motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical)
            }
            else
            {
                guard self.motionManager.isDeviceMotionActive else
                {
                    return
                }
                
                self.motionManager.stopDeviceMotionUpdates()
            }
        }
    }
    
    deinit
    {
        self.enabled = false
    }
    
    init()
    {
        guard self.motionManager.isDeviceMotionAvailable else
        {
            return
        }
        
        self.motionManager.deviceMotionUpdateInterval = type(of: self).DeviceMotionUpdateInterval
    }
}

