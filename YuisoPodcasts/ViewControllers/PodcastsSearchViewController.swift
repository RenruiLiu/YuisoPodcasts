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

    fileprivate let cellID = "cellID"
    var podcasts = [Podcast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTableView()
        
        searchBar(searchController.searchBar, textDidChange: "Voong")
    }
    
    //MARK:- table config
    
    // 1: register cell
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
    }
    
    // 2: numberOfRows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    // 3: cellforRow, dequeue cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PodcastCell
        cell.podcast = self.podcasts[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    // 4: header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No results, please enter a search query."
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .purple
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.count > 0 ? 0 : 250
    }
    
    // 5: didSelect
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodeVC = EpisodeViewController()
        episodeVC.podcast = podcasts[indexPath.row]
        navigationController?.pushViewController(episodeVC, animated: true)
    }
    
    //MARK:- Search
    
    let searchController = UISearchController(searchResultsController: nil)

    fileprivate func setupSearchBar() {
        self.definesPresentationContext = true // don't cover the new controller(so can see nav bar)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        APIService.shared.fetchPodcasts(searchText: searchBar.text ?? "") { (podcasts) in
//            // load the data into table and refresh table
//            self.podcasts = podcasts
//            self.tableView.reloadData()
//        }
//    }
    // input delay timer
    var timer: Timer?

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in

            APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
                // load the data into table and refresh table
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
        })
    }
}
