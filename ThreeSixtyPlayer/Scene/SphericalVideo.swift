//
//  VideoInfo.swift
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

struct SphericalVideo
{
    let urlString: String
    let resolution: CGSize
    let type: VideoType
    
    enum VideoType
    {
        case monoscopic
        case stereoscopic(layout: StereoscopicLayout)
        
        enum StereoscopicLayout
        {
            case topBottom
            case leftRight
        }
    }
}

extension SphericalVideo
{
    static let MonoscopicUrlString = "https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/649/7/178248880/580318297.mp4?token=938d3a52_0xfb2509dff5d09d6849327592792df58673fcca43"
    static let StereoscopicTopBottomUrlString = MonoscopicUrlString
    static let StereoscopicLeftRightUrlString = MonoscopicUrlString
    static let DefaultResolution = CGSize(width: 1920, height: 1080)

    static func demoVideo(ofType type: VideoType) -> SphericalVideo
    {
        switch type
        {
        case .monoscopic:
            return SphericalVideo(urlString: MonoscopicUrlString, resolution: DefaultResolution, type: type)

        case .stereoscopic(layout: let layout):
            switch layout
            {
            case .topBottom:
                return SphericalVideo(urlString: StereoscopicTopBottomUrlString, resolution: DefaultResolution, type: type)

            case .leftRight:
                return SphericalVideo(urlString: StereoscopicLeftRightUrlString, resolution: DefaultResolution, type: type)
            }
        }
    }
}

// "https://s3.amazonaws.com/ray.wenderlich/elephant_safari.mp4"
// From: https://www.raywenderlich.com/136692/introduction-google-cardboard-ios

// "http://www.kolor.com/360-videos-files/noa-neal-graffiti-360-music-video-full-hd.mp4"
// From : http://www.kolor.com

//"https://vimeo-prod-archive-std-us.storage.googleapis.com/videos/580317808?GoogleAccessId=GOOGHOVZWCHVINHSLPGA&Expires=1564090179&Signature=8ea%2Fk6n8I7%2FPr5yAoIbkoqINbyM%3D"

/*
 progressive: [
 {
 profile: 174,
 width: 1366,
 mime: "video/mp4",
 fps: 24,
 url: "https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/649/7/178248880/580318301.mp4?token=938d3a52_0x622cea9ad8cd5453dad0126d10246cef114c6395",
 cdn: "fastly",
 quality: "720p",
 id: 580318301,
 origin: "gcs",
 height: 682
 },
 {
 profile: 164,
 width: 640,
 mime: "video/mp4",
 fps: 24,
 url: "https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/649/7/178248880/580318298.mp4?token=938d3a52_0x02570a54a7eec023850ccc969b359e2a4d844176",
 cdn: "fastly",
 quality: "360p",
 id: 580318298,
 origin: "gcs",
 height: 320
 },
 {
 profile: 119,
 width: 1920,
 mime: "video/mp4",
 fps: 24,
 url: "https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/649/7/178248880/580318297.mp4?token=938d3a52_0xfb2509dff5d09d6849327592792df58673fcca43",
 cdn: "fastly",
 quality: "1080p",
 id: 580318297,
 origin: "gcs",
 height: 960
 },
 {
 profile: 165,
 width: 960,
 mime: "video/mp4",
 fps: 24,
 url: "https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/649/7/178248880/580318294.mp4?token=938d3a52_0xd94601765e12b284ed8f2e9d77ba9a5b6965d1ee",
 cdn: "fastly",
 quality: "540p",
 id: 580318294,
 origin: "gcs",
 height: 480
 }
 ]
 */

