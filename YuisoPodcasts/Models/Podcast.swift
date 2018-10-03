//
//  Podcast.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 3/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import FeedKit

struct Podcast:Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}

struct Episode {
    let pubDate: Date
    let description: String
    let title: String
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.description = feedItem.description ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        
    }
}
