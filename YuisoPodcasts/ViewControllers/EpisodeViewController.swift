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
    
    fileprivate func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = episodes[indexPath.row].title
        return cell
    }

    //MARK:- fetch Episodes
    fileprivate func fetchEpisodes(){
        guard let feedUrl = podcast?.feedUrl else {return}
        let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https") // avoid App Transport Security block issue
        guard let url = URL(string: secureFeedUrl) else {return}
        let parser = FeedParser(URL: url)
        parser.parseAsync { (result) in
            
            // result of itunes feedurl will always be rss
            switch result {
            case let .rss(feed):
                
                var episodes = [Episode]()
                feed.items?.forEach({ (feedItem) in
                    let episode = Episode(title: feedItem.title ?? "")
                    episodes.append(episode)
                })
                self.episodes = episodes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                break
            case .atom(_): break
            case .json(_): break
            case let .failure(error):
                print("Failed to parse url:", error)
                break
            }
        }
    }
}
