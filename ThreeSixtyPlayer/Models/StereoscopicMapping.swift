//
//  StereoscopicMapping.swift
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

import Foundation
import CoreGraphics

enum StereoscopicMapping
{
    case top
    case bottom
    case left
    case right
}

extension StereoscopicMapping
{
    var videoNodeAnchorPoint: CGPoint
    {
        switch self
        {
        case .top:
            return CGPoint(x: 0.5, y: 0.75)
            
        case .bottom:
            return CGPoint(x: 0.5, y: 0.25)
            
        case .left:
            return CGPoint(x: 0.25, y: 0.5)
            
        case .right:
            return CGPoint(x: 0.75, y: 0.5)
        }
    }
    
    func sceneSize(videoResolution: CGSize) -> CGSize
    {
        switch self
        {
        case .top, .bottom:
            return CGSize(width: videoResolution.width, height: videoResolution.height / 2)
            
        case .left, .right:
            return CGSize(width: videoResolution.width / 2, height: videoResolution.height)
        }
    }
}

