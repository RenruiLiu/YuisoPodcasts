//
//  RSSFeed.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 4/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import FeedKit

extension RSSFeed {
    func toEpisode() -> [Episode] {
        var episodes = [Episode]()
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            if episode.imageUrl == nil {
                // give it a default image Url(the podcast image)
                let imageUrl = iTunes?.iTunesImage?.attributes?.href
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        return episodes
    }
}

