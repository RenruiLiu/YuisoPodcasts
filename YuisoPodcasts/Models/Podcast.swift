//
//  Podcast.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 3/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import FeedKit

class Podcast:NSObject, Decodable, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    let trackNameKey = "trackNameKey"
    let artistNameKey = "artistNameKey"
    let artworkUrlKey = "artworkUrlKey"
    let feedUrlKey = "feedUrlKey"
    
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackName, forKey: trackNameKey)
        aCoder.encode(artistName, forKey: artistNameKey)
        aCoder.encode(artworkUrl600, forKey: artworkUrlKey)
        aCoder.encode(feedUrl, forKey: feedUrlKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.trackName = aDecoder.decodeObject(forKey: trackNameKey) as? String
        self.artistName = aDecoder.decodeObject(forKey: artistNameKey) as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: artworkUrlKey) as? String
        self.feedUrl = aDecoder.decodeObject(forKey: feedUrlKey) as? String
    }
}

struct Episode {
    let pubDate: Date
    let description: String
    let title: String
    var imageUrl: String?
    let author: String
    let streamUrl: String
    
    init(feedItem: RSSFeedItem) {
        title = feedItem.title ?? ""
        description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        pubDate = feedItem.pubDate ?? Date()
        imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        author = feedItem.iTunes?.iTunesAuthor ?? ""
        streamUrl = feedItem.enclosure?.attributes?.url ?? ""
    }
}
