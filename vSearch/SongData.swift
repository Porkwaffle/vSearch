//
//  SongData.swift
//  vSearch
//
//  Created by Ross Lubinski on 8/22/18.
//  Copyright © 2018 Ross Lubinski. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import SwiftSpinner

var searchItem : String = "The Voice Performance"
//var searchItem : String = "Eminem"

class SongData {
    
    func getSongData(returnSongData : @escaping ([Song]) -> Void) {
        Alamofire.request("https://itunes.apple.com/us/rss/topsongs/limit=200/explicit=true/json", method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                let songJSON : JSON = JSON(response.result.value!)
                let songs = songJSON["feed"]["entry"]
                
                //Create an array of song objects
                var songArray = [Song]()
                
                var i: Int = 0
                for song in songs.arrayValue {
                    //Search "SongName - ArtistName" for desired string
                    if songs[i]["title"]["label"].stringValue.lowercased().contains(searchItem.lowercased()) {
                        let artistName = song["im:artist"]["label"].stringValue
                        let songName = song["im:name"]["label"].stringValue.replacingOccurrences(of: "(The Voice Performance)", with: "")
                        let imageURL = song["im:image"][2]["label"].stringValue
                        let itunesLink = song["category"]["attributes"]["scheme"].stringValue
                        let previewLink = song["link"][1]["attributes"]["href"].stringValue
                        let itunesRanking = String("# \(i + 1)")
                        
                        //Create a new song object and add it to song array
                        let songObject = Song()
                        songObject.artistName = artistName
                        songObject.songName = songName
                        songObject.imageURL = imageURL
                        songObject.itunesLink = itunesLink
                        songObject.previewLink = previewLink
                        songObject.itunesRanking = itunesRanking
                        songArray.append(songObject)
                    }
                        
                    i += 1
                }
                returnSongData(songArray)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                SwiftSpinner.show("Service Unavailable", animated: false).addTapHandler({
                    SwiftSpinner.hide()
                })
            }
        }
    }
    
}

class Song {
    var artistName = ""
    var songName = ""
    var imageURL = ""
    var itunesLink = ""
    var previewLink = ""
    var itunesRanking = ""
}
