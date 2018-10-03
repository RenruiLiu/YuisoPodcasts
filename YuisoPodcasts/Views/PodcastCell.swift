//
//  PodcastCell.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 3/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var EpisodeCountLabel: UILabel!
    @IBOutlet weak var ArtistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var podcastImageView: UIImageView!
    
    var podcast: Podcast!{
        didSet{
            trackNameLabel.text = podcast.trackName
            ArtistNameLabel.text = podcast.artistName
            EpisodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else {return}
            podcastImageView.sd_setImage(with: url, completed: nil)
            
//            // use URLSession
//            URLSession.shared.dataTask(with: url) { (data, _, err) in
//                if let err = err {
//                    print("Failed to fetch url data:",err)
//                    return
//                }
//                guard let data = data else {return}
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//            }.resume()
            
        }
    }
    
}
