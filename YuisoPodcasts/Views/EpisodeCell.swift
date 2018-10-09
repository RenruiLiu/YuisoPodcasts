//
//  EpisodeCell.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 4/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var episodeImageVIew: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var episode: Episode! {
        didSet{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            descriptionLabel.text = episode.description
            titleLabel.text = episode.title
            
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImageVIew.sd_setImage(with: url, completed: nil)
        }
    }
}
