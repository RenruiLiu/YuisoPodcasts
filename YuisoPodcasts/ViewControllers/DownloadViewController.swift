//
//  ViewController.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 3/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class DownloadViewController: UITableViewController {

    fileprivate let cellID = "cellID"
    var episodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = nil
    }
    
    //MARK:- setup
    fileprivate func setupTableView(){
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
    }
    
    fileprivate func setupObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    @objc fileprivate func handleDownloadComplete(notification: Notification){
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else {return}
        let index = self.episodes.firstIndex { (e) -> Bool in
            e.title == episodeDownloadComplete.episodeTitle
        }
        if index == nil {return}
        self.episodes[index!].fileUrl = episodeDownloadComplete.fileUrl
    }
    
    @objc fileprivate func handleDownloadProgress(notification: Notification){
        // listen to observer
        guard let userInfo = notification.userInfo as? [String: Any] else {return}
        guard let progress = userInfo["progress"] as? Double else {return}
        guard let title = userInfo["title"] as? String else {return}
        
        // update table cell
        let index = self.episodes.firstIndex { (e) -> Bool in
            e.title == title
        }
        if index == nil {return}
        guard let cell = tableView.cellForRow(at: IndexPath(row: episodes.count - 1 - index!, section: 0)) as? EpisodeCell else {return}
        cell.progressLabel.text = "\(Int(progress * 100))%"
        
        if progress == 1.0 {
            cell.progressLabel.isHidden = true
        } else {cell.progressLabel.isHidden = false}
        
    }

    //MARK:- TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
        cell.episode = episodes[episodes.count - indexPath.row - 1]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexpath) in
            let index = self.episodes.count - indexPath.row - 1
            self.handleDeleteFile(index: index) // delete file
            let episode = self.episodes[index]
            self.episodes.remove(at: index) // delete from list
            tableView.deleteRows(at: [indexPath], with: .automatic) // delete from UI
            UserDefaults.standard.deleteEpisode(episode: episode) // delete from userDefauts
        }
        return [deleteAction]
    }
    
    fileprivate func handleDeleteFile(index: Int){
        // get the name of file
        guard let fileURL = URL(string: episodes[index].fileUrl ?? "") else {return}
        let trueLocation = getLocalLocation(fileURL: fileURL)
        
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(at: trueLocation)
        }catch let err {
            print("Failed to delete local file:",err)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[episodes.count - indexPath.row - 1]
        
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximizePlayerView(episode: episode, playListEpisodes: episodes.reversed())
        } else {
            let alertController = UIAlertController(title: "File URL not found", message: "Cannot find local file, playing podcast using your network?", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                UIApplication.mainTabBarController()?.maximizePlayerView(episode: episode, playListEpisodes: self.episodes.reversed())
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true)
        }
    }
}

func getLocalLocation(fileURL: URL) -> URL{
    // get the name of file
    let fileName = fileURL.lastPathComponent
    // get the directory of application document (because it changes often)
    guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return fileURL}
    trueLocation.appendPathComponent(fileName)
    return trueLocation
}
