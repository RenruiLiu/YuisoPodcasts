//
//  PodcastsSearchViewController.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 3/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchViewController: UITableViewController, UISearchBarDelegate {

    let cellID = "cellID"
    var podcasts = [
        Podcast(trackName: "YuisoPodcast", artistName: "Yuiso"),
        Podcast(trackName: "YuisoPodcast1", artistName: "Yuiso1"),
        Podcast(trackName: "YuisoPodcast2", artistName: "Yuiso2"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTableView()
    }
    
    //MARK:- table config
    
    // 1: register cell
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    // 2: numberOfRows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    // 3: cellforRow, dequeue cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let podcast = self.podcasts[indexPath.row]
        cell.textLabel?.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
        cell.textLabel?.numberOfLines = -1
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        
        return cell
    }
    
    //MARK:- Search
    
    let searchController = UISearchController(searchResultsController: nil)

    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
            // load the data into table and refresh table
            self.podcasts = podcasts
            self.tableView.reloadData()
        }
    }
}
