//
//  CoreGraphics+Extensions.swift
//  ThreeSixtyPlayer
//
//  Created by Alfred Hanssen on 10/8/16.
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

import CoreGraphics

extension CGSize
{
    /// Returns the midpoint of the receiver's width.
    var midX: CGFloat
    {
        return self.width / 2
    }
    
    /// Returns the midpoint of the receiver's height.
    var midY: CGFloat
    {
        return self.height / 2
    }
    
    /// Returns the midpoint of the receiver's width and height.
    var midPoint: CGPoint
    {
        return CGPoint(x: self.midX, y: self.midY)
    }
    
    /// Returns a boolean indicating whether the receiver's width and height are both greater than zero.
    var isGreaterThanZero: Bool
    {
        return self.width > 0 && self.height > 0
    }
    
    // TODO: Does this belong here?
    static var DefaultVideoResolution: CGSize
    {
        return CGSize(width: 1920, height: 1080)
    }
}
