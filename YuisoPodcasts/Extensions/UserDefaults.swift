//
//  UserDefaults.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 7/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadedEpisodeKey = "downloadedEpisodeKey"
    
    func savedPodcasts() -> [Podcast] {

        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else {return []}
        do {
            guard let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastsData) else {return []}
            return savedPodcasts as? [Podcast] ?? []
        } catch let err {print(err)}
        return []
    }
    
    func setPodcasts(podcasts: [Podcast]) {
        
        // archive it to NSData, then set to userDefaults
        do {
            try UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: podcasts, requiringSecureCoding: true), forKey: UserDefaults.favoritedPodcastKey)
        } catch let err {
            print(err)
        }
    }
    
    func downloadEpisode(episode: Episode){
        do {
            var episodes = downloadedEpisodes()
            episodes.append(episode)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
            
        } catch let encodeErr {print("Failed to encode:", encodeErr)}
    }
    
    func downloadedEpisodes() -> [Episode]{
        guard let episodeData = data(forKey: UserDefaults.downloadedEpisodeKey) else {return []}
        
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodeData)
            return episodes
        } catch let decodeErr {print("Failed to decode:",decodeErr)}
        return []
    }
    
    func deleteEpisode(episode: Episode) {
        let episodes = downloadedEpisodes()
        let filteredEpisodes = episodes.filter { (e) -> Bool in
            return e.title != episode.title || e.author != episode.author
        }
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
        } catch let encodeErr {print("Failed to encode:", encodeErr)}
    }
}
