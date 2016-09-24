//
//  PlaylistViewController.swift
//  360Player
//
//  Created by Alfred Hanssen on 9/14/16.
//  Copyright © 2016 Alfie Hanssen. All rights reserved.
//

import UIKit
import AVFoundation

class PlaylistViewController: UIViewController
{
    private static let UrlString = "https://vimeo-prod-archive-std-us.storage.googleapis.com/videos/580317808?GoogleAccessId=GOOGHOVZWCHVINHSLPGA&Expires=1564090179&Signature=8ea%2Fk6n8I7%2FPr5yAoIbkoqINbyM%3D"
    
    @IBAction func didTapButton(_ sender: UIButton)
    {
        let string = type(of: self).UrlString
        let url = URL(string: string)!
        let urlAsset = AVURLAsset(url: url)
        let player = AVPlayer(url: url)
        
        //player.volume = 0
        
        guard let videoSize = urlAsset.encodedResolution() else // TODO: Does this capture screen scale? [AH] 7/7/2016
        {
            assertionFailure("Unable to access encoded resolution for video resource.")
            
            return
        }
        
        let viewController = ThreeSixtyViewController(player: player, videoSize: videoSize)        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
