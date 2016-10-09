//
//  SphericalVideo.swift
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

struct Video
{
    let urlString: String
    let resolution: CGSize
    let type: VideoType
}

extension Video
{
    static let Mono = "https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/649/7/178248880/580318297.mp4?token=938d3a52_0xfb2509dff5d09d6849327592792df58673fcca43"
    static let StereoTopBottom = "https://player.vimeo.com/external/186023974.m3u8?s=2653db76dd0b3dcaa19b21d0969d42531b1c102a"
    static let StereoLeftRight = StereoTopBottom
    
    static let DefaultMonoResolution = CGSize(width: 1920, height: 1080)
    static let DefaultStereoResolution = CGSize(width: 1080, height: 1080) // TODO: For HLS/DASH we don't want to rely on w/h

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

// https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/649/7/178248880/580318297.mp4?token=938d3a52_0xfb2509dff5d09d6849327592792df58673fcca43
// http://www.kolor.com/360-videos-files/noa-neal-graffiti-360-music-video-full-hd.mp4

