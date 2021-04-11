//
//  Player.swift
//  DNB-Share.com
//
//  Created by M1 on 19/03/2021.
//

import Foundation
import AVFoundation

var player: AVPlayer! = nil


class Play: AVPlayer {
    
    var url: URL
    override init(url: URL) {
    self.url = url
        super.init()
        playMusic(url: self.url)
    }
    
    
    func playMusic(url : URL) {
 
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        if player == nil {
                player = AVPlayer(playerItem: playerItem)
            if player.status.rawValue == 0 {
              player.play()
              
                }
                } else {
                player.replaceCurrentItem(with: playerItem)
                player.play()
                }
    }
  

}
