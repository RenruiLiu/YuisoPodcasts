//
//  FavoritePodcastCell.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 7/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class FavoritePodcastCell: UICollectionViewCell {
    
    var podcast: Podcast! {
        didSet{
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            let url = URL(string: podcast.artworkUrl600 ?? "")
            imageView.sd_setImage(with: url)
        }
    }
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return lb
    }()
    let artistNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.textColor = .lightGray
        return lb
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView(){
        let stackView = UIStackView(arrangedSubviews: [imageView,nameLabel,artistNameLabel])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.anchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 0)
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
}
