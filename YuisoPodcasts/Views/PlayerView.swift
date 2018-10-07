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
        playbtn.isEnabled = false
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
    
    @objc fileprivate func handlePlayPause(){
        if player.timeControlStatus == .paused {
            player.play()
            playbtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            self.setupLockScreenElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playbtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
            self.setupLockScreenElapsedTime(playbackRate: 0)
        }
    }
    
    @IBAction fileprivate func handleCurrentTimeSliderChange(_ sender: UISlider) {
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
    
    @IBAction fileprivate func rewindBtn(_ sender: UIButton) {
        seekTime(fromCurrent: -15)
    }
    
    @objc fileprivate func handleFastfoward(){
        seekTime(fromCurrent: 15)
    }
    
    @IBAction fileprivate func handleVolumeChange(_ sender: UISlider) {
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
            setupAudioSession()
            
            setupNowPlayingInfo()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupScrollTitle()
        setupGestures()
        observePlayerStarts()
        observePlayerCurrentTime()
        setupRemoteControl()
        setupRouteChange()
        setupInterruptionObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
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
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }

        // control play pause, like button in earphone
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))

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
    
    fileprivate func setupLockScreenElapsedTime(playbackRate: Float){
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        
        // playback rate fixes that OS think the track is still playing when you actually pause it
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    //MARK:- pre next track
    
    var playListEpisodes = [Episode]()
    
    @objc fileprivate func handleNextTrack(){
        print("next")
        changeToNextOrPreviousTrack(toNext: true)
    }
    
    @objc fileprivate func handlePreviousTrack(){
        print("pre")
        changeToNextOrPreviousTrack(toNext: false)
    }
    
    fileprivate func changeToNextOrPreviousTrack(toNext: Bool){
        if playListEpisodes.count == 0 {return}
        let currentEpisodeIndex = playListEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        guard let index = currentEpisodeIndex else {return}
        let nextEpisode: Episode
        
        if toNext {
            if index == playListEpisodes.count - 1 {
                nextEpisode = playListEpisodes[0]
            } else {
                nextEpisode = playListEpisodes[index + 1]
            }
        } else {
            if index == 0 {
                nextEpisode = playListEpisodes[playListEpisodes.count - 1]
            } else {
                nextEpisode = playListEpisodes[index - 1]
            }
        }
        self.episode = nextEpisode
        print(nextEpisode.title)
    }
    
    //MARK:- handle interruption
    
    fileprivate func setupInterruptionObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(note: Notification){
        guard let userinfo = note.userInfo else {return}
        guard let type = userinfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        if type == AVAudioSession.InterruptionType.began.rawValue {
            // pause it
            playbtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            // interruption ended // resume
            guard let options = userinfo[AVAudioSessionInterruptionOptionKey] as? UInt else {return}
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playbtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }
    
    
}
