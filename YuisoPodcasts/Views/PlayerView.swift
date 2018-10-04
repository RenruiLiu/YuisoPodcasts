//
//  PlayerView.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 4/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import AVKit

class PlayerView: UIView {
    
    var episode: Episode!{
        didSet{
            episodeTitleLabel.text = episode.title
            authorLabel.text = episode.author
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
            
            playEpisode()
            playbtn.isEnabled = false
        }
    }

    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playbtn: UIButton!
    @IBOutlet weak var episodeTitleLabel: UILabel! 
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!{
        didSet{
            episodeImageView.transform = shrunkenTransform
        }
    }

    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate func playEpisode(){
        
        guard let url = URL(string: episode.streamUrl) else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    //MARK:- animation
    
    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    fileprivate func enlargeEpisodeImageView(){
        // spring = 弹簧
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity // identity = its original state
        })
    }
    fileprivate func shrinkEpisodeImageView(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrunkenTransform
        })

    }
    
    //MARK:- IBActions
    
    @IBAction func handleDismiss(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func playPauseBtn(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            player.play()
            sender.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            sender.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
        }
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: UISlider) {
        let percentage = sender.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSec = CMTimeGetSeconds(duration)
        let seekTimeInSec = durationInSec * Float64(percentage)
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSec, preferredTimescale: Int32(NSEC_PER_SEC))
        player.seek(to: seekTime)
    }
    
    fileprivate func seekTime(fromCurrent seconds: Int64) {
        let seconds = CMTimeMake(value: seconds, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), seconds)
        player.seek(to: seekTime)
    }
    
    @IBAction func rewindBtn(_ sender: UIButton) {
        seekTime(fromCurrent: -15)
    }
    
    @IBAction func fastforwardBtn(_ sender: UIButton) {
        seekTime(fromCurrent: 15)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    fileprivate func updateCurrentTimeSlider(){
        let currentTimeSec = CMTimeGetSeconds(player.currentTime())
        let durationTimeSec = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1,timescale: 1))
        let percentage = currentTimeSec / durationTimeSec
        self.currentTimeSlider.value = Float(percentage)
    }

    
    //MARK:- view
    
    // equals to viewDidLoad()
    fileprivate func observePlayerCurrentTime() {
        // update the time every half second
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            
            self?.currentTimeLabel.text = time.toDisplayString()
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func observePlayerStarts() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        // observe when the player starts to play
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            [weak self] in
            self?.playbtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self?.playbtn.isEnabled = true
            self?.enlargeEpisodeImageView()
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        observePlayerStarts()
        observePlayerCurrentTime()
    }
}
