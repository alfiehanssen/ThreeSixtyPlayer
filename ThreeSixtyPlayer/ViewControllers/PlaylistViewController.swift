//
//  PlaylistViewController.swift
//  ThreeSixtyPlayer
//
//  Created by Alfred Hanssen on 9/14/16.
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

import UIKit
import AVFoundation

class PlaylistViewController: UIViewController
{    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.title = NSLocalizedString("Media List", comment: "The title of the Media List view controller.")
    }
    
    @IBAction func didTapMonoscopicButton(_ sender: UIButton)
    {
        let video = Video.demoVideo(ofType: .monoscopic)
        self.presentMonoscopicPlayerViewController(withVideo: video)
    }

    @IBAction func didTapStereoscopicTopBottomButton(_ sender: UIButton)
    {
        let video = Video.demoVideo(ofType: .stereoscopic(layout: .topBottom))
        self.presentStereoscopicPlayerViewController(withVideo: video)
    }

    @IBAction func didTapStereoscopicLeftRightButton(_ sender: UIButton)
    {
        let video = Video.demoVideo(ofType: .stereoscopic(layout: .leftRight))
        self.presentStereoscopicPlayerViewController(withVideo: video)
    }

    private func presentMonoscopicPlayerViewController(withVideo video: Video)
    {
        let player = AVPlayer()
        let viewController = MonoscopicViewController(player: player)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(4000)) {
            viewController.video = video
        }
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    private func presentStereoscopicPlayerViewController(withVideo video: Video)
    {
        let player = AVPlayer()
        let viewController = StereoscopicViewController()

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(4000)) {
            viewController.video = video
        }
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

