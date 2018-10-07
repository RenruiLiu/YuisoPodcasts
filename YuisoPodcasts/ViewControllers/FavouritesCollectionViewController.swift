//
//  FavouriteViewControllerCollectionViewController.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 7/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

private let cellID = "Cell"

class FavouritesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var podcasts = UserDefaults.standard.savedPodcasts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refetch podcasts every time view shows up
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = nil
    }
    
    //MARK:- Collection View
    
    fileprivate func setupCollectionView(){
        collectionView.backgroundColor = .white
        self.collectionView!.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellID)
        
        // delete gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc fileprivate func handleLongPress(gesture: UILongPressGestureRecognizer){
        let location = gesture.location(in: collectionView)
        guard let selectedIndexPath = collectionView.indexPathForItem(at: location) else {return}
        
        // present alert sheet
        let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            self.podcasts.remove(at: selectedIndexPath.item)
            self.collectionView.deleteItems(at: [selectedIndexPath])

            // remove it from userdefaults
            UserDefaults.standard.setPodcasts(podcasts: self.podcasts)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! FavoritePodcastCell
        cell.podcast = podcasts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3 * 16) / 2
        return CGSize(width: width, height: width + 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodeController = EpisodeViewController()
        episodeController.podcast = self.podcasts[indexPath.item]
        navigationController?.pushViewController(episodeController, animated: true)
    }

}
