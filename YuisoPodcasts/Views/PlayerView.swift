//
//  PlayerView.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 4/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import EFAutoScrollLabel

class PlayerView: UIView {
    
    //MARK:- IBOutlet

    @IBOutlet weak var miniImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseBtn: UIButton! {
        didSet{
            miniPlayPauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
            miniPlayPauseBtn.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
    }
    @IBOutlet weak var miniFastforwardBtn: UIButton! {
        didSet{
            miniFastforwardBtn.addTarget(self, action: #selector(handleFastfoward), for: .touchUpInside)
            miniFastforwardBtn.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
    }
    @IBOutlet weak var miniPlayerView: UIView!
    
    @IBOutlet weak var miniStackView: UIStackView!
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playbtn: UIButton! {
        didSet{
            playbtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @IBOutlet weak var fastforwardBtn: UIButton! {
        didSet{
            fastforwardBtn.addTarget(self, action: #selector(handleFastfoward), for: .touchUpInside)
        }
    }
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
    
    @objc func handlePlayPause(){
        if player.timeControlStatus == .paused {
            player.play()
            playbtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playbtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
        }
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: UISlider) {
        let percentage = sender.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSec = CMTimeGetSeconds(duration)
        let seekTimeInSec = durationInSec * Float64(percentage)
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSec, preferredTimescale: Int32(NSEC_PER_SEC))
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSec
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
    
    @objc func handleFastfoward(){
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
            
            //set up lock screen time
            self?.setupLockScreenDuration()
        }
    }
    
    //MARK:- Setup
    
    var episode: Episode!{
        didSet{
            episodeTitleLabel.text = episode.title
            authorLabel.text = episode.author
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
            
            scrollLabel.text = episode.title
            miniImageView.sd_setImage(with: url) { (image, _, _, _) in
                // set lock screen artwork as well at the same time
                let image = self.episodeImageView.image ?? UIImage()
                let artwork = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (_) -> UIImage in
                    return image
                })
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            }
            
            playEpisode()
            playbtn.isEnabled = false
            
            setupNowPlayingInfo()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupScrollTitle()
        setupGestures()
        observePlayerStarts()
        observePlayerCurrentTime()
        setupAudioSession()
        setupRemoteControl()
        setupRouteChange()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // scroll label
    let scrollLabel = EFAutoScrollLabel()
    fileprivate func setupScrollTitle() {
        scrollLabel.font = UIFont.systemFont(ofSize: 15)
        miniStackView.insertSubview(scrollLabel, aboveSubview: miniTitleLabel)
        
        scrollLabel.anchor(top: miniTitleLabel.topAnchor, paddingTop: 0, bottom: miniTitleLabel.bottomAnchor, paddingBottom: 0, left: miniTitleLabel.leftAnchor, paddingLeft: 0, right: miniTitleLabel.rightAnchor, paddingRight: 0, width: 0, height: 0)
        miniTitleLabel.alpha = 0
    }
    
    static func initFromNib() -> PlayerView {
        return Bundle.main.loadNibNamed("PlayerView", owner: self, options: nil)?.first as! PlayerView
    }
    
    //MARK:- max and minimize view
    @IBAction func handleDismiss(_ sender: UIButton) {
        UIApplication.mainTabBarController()?.minimizePlayerView()
    }
    
    @objc func handleTapMaximize(){
        UIApplication.mainTabBarController()?.maximizePlayerView(episode: nil)
    }
    
    //MARK:- Gesture
    
    var panGesture: UIPanGestureRecognizer!
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: superview)
        if gesture.state == .changed {
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
    
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                 self.maximizedStackView.transform = .identity
                if translation.y > 50 {
                    UIApplication.mainTabBarController()?.minimizePlayerView()
                }
            })
        }
    }
    
    //MARK:- background play
    
    fileprivate func setupAudioSession(){
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionErr {
            print("Failed to activate session:", sessionErr)
        }
    }

    fileprivate func setupRemoteControl(){
        
        // access the remote controller
        UIApplication.shared.beginReceivingRemoteControlEvents()

        let commandCenter = MPRemoteCommandCenter.shared()

        // control play pause, like button in earphone
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            self.setupLockScreenElapsedTime()
            return .success
        }

    }
    
    // detect earphone plug in/out
    fileprivate func setupRouteChange(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChanged), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc func handleRouteChanged(note: Notification){
        if let userInfo = note.userInfo {
            // reason 2: plug out earphone
            // reason 1: plug in earphones
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? Int, reason == 2 {
                print("time to do sm")
                changePlayButtonImage()
            }
        }
    }
    
    func changePlayButtonImage(){
        DispatchQueue.main.async {
            self.player.pause()
            self.playbtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    //MARK:- lock screen
    
    fileprivate func setupNowPlayingInfo(){
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        // the lock screen center
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func setupLockScreenDuration(){
        
        // set duration // magically it gets current time as well
        guard let currentItem = player.currentItem else {return}
        let durationInSec = CMTimeGetSeconds(currentItem.duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSec
    }
    
    fileprivate func setupLockScreenElapsedTime(){
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
    }
    
}
