//
//  APIService.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 3/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    static let shared = APIService()
    // so can call functions in the class like: APISerice.shared.fetchxxx()
    
    // itunes API
    let iTunesSearchURL = "https://itunes.apple.com/search"
    
    func downloadEpisode(episode: Episode){
        // store file in file manager
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            // completion percetage: progress.fractionCompleted
            print(progress.fractionCompleted)
            }.response { (response) in
                // the location of downloaded file : response.destinationURL?.absoluteString
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
                guard let index = downloadedEpisodes.firstIndex(where: { (ep) -> Bool in
                    ep.title == episode.title && ep.author == episode.author
                }) else {return}
                // get the episode and append a url on it
                downloadedEpisodes[index].fileUrl = response.destinationURL?.absoluteString ?? ""
                do {
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
                    UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = "New"
                    
                } catch let encodeErr {print("Failed to encode:", encodeErr)}
        }
    }
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode])->()){
        guard let url = URL(string: feedUrl) else {return}
        
        // feedParser is parsing the url synchronously (block the UI thread)
        // so put it in a background thread
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            parser.parseAsync { (result) in
                
                if let err = result.error {
                    print("Failed to parse url:", err)
                    return
                }
                
                // result of itunes feedurl will always be rss
                guard let feed = result.rssFeed else {return}
                completionHandler(feed.toEpisode())
            }
        }
    }
    
    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast])->()){
        
        // request
        //let parameters = ["term": searchText, "media": "music"]
        let parameters = ["term": searchText, "media": "podcast"]
        Alamofire.request(iTunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("Failed to request the url:",err)
                return
            }
            // get response data
            guard let data = dataResponse.data else {return}
            
            // decode data from json to SearchResults
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                completionHandler(searchResult.results)
            } catch let decodeErr {
                print("Failed to decode:",decodeErr)
            }
        }
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast] //cast results to Podcast
    }
}
