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
}
