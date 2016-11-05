//
//  Video.swift
//  ThreeSixtyPlayer
//
//  Created by Alfred Hanssen on 10/6/16.
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

public extension Video
{
    static let Mono = "https://player.vimeo.com/external/187856429.m3u8?s=70eca31df2bc0f134331bb230e80dea855c0a8b0"
    static let StereoTopBottom = "https://player.vimeo.com/external/189658493.m3u8?s=e7ce8dc8f367e42df0a22279ccb82fbbe08c0a85"
    static let StereoLeftRight = StereoTopBottom // TODO: Need a left/right resource.
    
    static let DefaultMonoResolution = CGSize(width: 1920, height: 1080) // TODO: I believe the correct resolution is 1920x960.
    static let DefaultStereoResolution = CGSize(width: 1080, height: 1080) // TODO: For HLS/DASH we don't want to rely on w/h just aspect ratio.

    static func demoVideo(ofType type: VideoType) -> Video
    {
        switch type
        {
        case .monoscopic:
            return Video(urlString: Mono, resolution: DefaultMonoResolution, type: type)

        case .stereoscopic(layout: let layout):
            switch layout
            {
            case .topBottom:
                return Video(urlString: StereoTopBottom, resolution: DefaultStereoResolution, type: type)

            case .leftRight:
                return Video(urlString: StereoLeftRight, resolution: DefaultStereoResolution, type: type)
            }
        }
    }
}

