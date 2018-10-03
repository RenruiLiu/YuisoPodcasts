//
//  APIService.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 3/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import Alamofire

class APIService {
    
    // itunes API
    let iTunesSearchURL = "https://itunes.apple.com/search"

    static let shared = APIService()
    
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
