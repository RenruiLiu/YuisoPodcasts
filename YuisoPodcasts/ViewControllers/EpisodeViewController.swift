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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
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

        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController
        mainTabBarController?.maximizePlayerView(episode: episode)
        
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
