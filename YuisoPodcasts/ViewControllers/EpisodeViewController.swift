//
//  EpisodeViewController.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 3/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import FeedKit

class EpisodeViewController: UITableViewController {

    fileprivate let cellID = "cellID"

    var episodes = [Episode]()
    
    var podcast: Podcast?{
        didSet{
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }

    var savedPodcasts = UserDefaults.standard.savedPodcasts()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBarButtons()
    }
    
    fileprivate func setupNavigationBarButtons(){
        
        // check isPodcastFavorited
        let hasFavorited = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName}) != nil
        if hasFavorited {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfavorite", style: .plain, target: self, action: #selector(handleUnfavorite))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleFavorite))
        }
    }
    
    @objc fileprivate func handleFavorite(){
        var podcastsList = UserDefaults.standard.savedPodcasts()
        guard let podcast = self.podcast else {return}
        podcastsList.append(podcast)
        UserDefaults.standard.setPodcasts(podcasts: podcastsList)
        
        // set badge
        showBadgeHighlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfavorite", style: .plain, target: self, action: #selector(handleUnfavorite))
    }
    
    fileprivate func showBadgeHighlight(){
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = "New"
    }
    
    @objc fileprivate func handleUnfavorite(){
        
        // get index and remove it from list
        guard let podcastIndex = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName}) else {return}
        savedPodcasts.remove(at: podcastIndex)
        
        // present alert sheet
        let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            
            // remove it from UserDefaults
            UserDefaults.standard.setPodcasts(podcasts: self.savedPodcasts)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(self.handleFavorite))
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)

        
    }
    
    
    //MARK:- table config
    
    // present a loading circle while loading
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if episodes.isEmpty {
            let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
            activityIndicatorView.color = .darkGray
            activityIndicatorView.startAnimating()
            return activityIndicatorView
        } else {
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 200
    }
    
    fileprivate func setupTableView(){
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]

        UIApplication.mainTabBarController()?.maximizePlayerView(episode: episode, playListEpisodes: self.episodes)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _indexpath) in
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode: episode)
            
            //
            APIService.shared.downloadEpisode(episode: episode)
        }
        return [downloadAction]
    }
    
    //MARK:- fetch Episodes
    fileprivate func fetchEpisodes(){
        guard let feedUrl = podcast?.feedUrl?.toSecureHTTPS() else {return}

        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}
