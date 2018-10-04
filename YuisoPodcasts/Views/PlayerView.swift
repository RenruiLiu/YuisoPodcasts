//
//  PlayerView.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 4/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class PlayerView: UIView {
    
    var episode: Episode!{
        didSet{
            episodeTitleLabel.text = episode.title
            authorLabel.text = episode.author
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
        }
    }

    @IBOutlet weak var episodeTitleLabel: UILabel! 
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBAction func handleDismiss(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    @IBAction func playPauseBtn(_ sender: UIButton) {
    }
    @IBAction func rewindBtn(_ sender: UIButton) {
    }
    @IBAction func fastforwardBtn(_ sender: UIButton) {
    }
}
