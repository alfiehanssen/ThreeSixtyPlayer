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
import AVFoundation

struct Video
{
    let urlString: String
    let resolution: CGSize
    let type: VideoType
}

extension Video
{
    static let Mono = "http://www.kolor.com/360-videos-files/freedom360-hang-gliding-4k.mp4"
    static let StereoTopBottom = "https://player.vimeo.com/external/186023974.hd.mp4?s=eb6a035fd1742461f41ed6da84a36418985d54ba&profile_id=119"
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

extension Video
{
    var playerItem: AVPlayerItem
    {
        let url = URL(string: self.urlString)!
        let playerItem = AVPlayerItem(url: url)

        return playerItem
    }
}

