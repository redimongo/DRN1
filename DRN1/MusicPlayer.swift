//
//  MusicPlayer.swift
//  DRN1
//
//  Created by Russell Harrower on 25/11/19.
//  Copyright © 2019 Russell Harrower. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import Kingfisher

class MusicPlayer {
    static let shared = MusicPlayer()
    var player: AVPlayer?

         
        func startBackgroundMusic() {
            
            self.setupRemoteTransportControls()
            let urlString = "http://stream.radiomedia.com.au:8003/stream"
            guard let url = URL.init(string: urlString)
                else {
                    return
            }
            let playerItem = AVPlayerItem.init(url: url)
            player = AVPlayer.init(playerItem: playerItem)
            
                       
            
            player?.play()
            
            do {
              //  try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers, .defaultToSpeaker, .mixWithOthers, .allowAirPlay])
                print("Playback OK")
                let defaults = UserDefaults.standard
                defaults.set("1", forKey: defaultsKeys.musicplayer_connected)
                try AVAudioSession.sharedInstance().setActive(true)
                print("Session is Active")
            } catch {
                let defaults = UserDefaults.standard
                defaults.set("0", forKey: defaultsKeys.musicplayer_connected)
                print(error)
            }
            
        }
        
    
   
    
    func setupRemoteTransportControls() {
       // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player?.rate == 0.0 {
                self.player?.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player?.rate == 1.0 {
                self.player?.pause()
                return .success
            }
            return .commandFailed
        }
        
       // self.nowplaying(artist: "Anna", song: "test")
        
        
    }
    
    func nowplaying(with artwork: MPMediaItemArtwork, artist: String, song: String){

    MPNowPlayingInfoCenter.default().nowPlayingInfo = [
          MPMediaItemPropertyTitle:song,
          MPMediaItemPropertyArtist:artist,
          MPMediaItemPropertyArtwork: artwork,
          MPNowPlayingInfoPropertyIsLiveStream: true
    ]
        
       
       // self.getArtBoard();
    }
    
    
    func setupNowPlayingInfo(with artwork: MPMediaItemArtwork) {
          MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            //   MPMediaItemPropertyTitle: "Some name",
            //   MPMediaItemPropertyArtist: "Some name",
               MPMediaItemPropertyArtwork: artwork,
               //MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(currentItem.duration),
               //MPNowPlayingInfoPropertyPlaybackRate: 1,
               //MPNowPlayingInfoPropertyElapsedPlaybackTime: CMTimeGetSeconds(currentItem.currentTime())
           ]
       }
    
    
    
    func getData(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let data = data {
                completion(UIImage(data:data))
            }
        })
            .resume()
    }

    func getArtBoard(artist: String, song: String, cover: String) {
        guard let url = URL(string: cover) else { return }
        getData(from: url) { [weak self] image in
            guard let self = self,
                let downloadedImage = image else {
                    return
            }
            let artwork = MPMediaItemArtwork.init(boundsSize: downloadedImage.size, requestHandler: { _ -> UIImage in
                return downloadedImage
            })
            self.nowplaying(with: artwork, artist: artist, song: song)
        }
    }
    
    
    
        func stopBackgroundMusic() {
            guard let player = player else { return }
            player.pause()
            
    }

    
}
