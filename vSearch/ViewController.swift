//
//  ViewController.swift
//  Voice Search
//
//  Created by Ross Lubinski on 8/22/18.
//  Copyright © 2018 Ross Lubinski. All rights reserved.
//
import UIKit
import Kingfisher
import ChameleonFramework
import AVFoundation
import SwiftSpinner

class ViewController: UIViewController {
    
    var songs = [Song]()
    var player: AVPlayer!
    let refreshControl = UIRefreshControl()
    var isPlaying : Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func imageTapped(_ sender: UIButton) {
        //Handle button press within a Cell
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        let url = URL.init(string: songs[(indexPath?.row)!].previewLink)
        player = AVPlayer.init(url: url!)
        
        if isPlaying == true {
            print("Pausing...")
            player.pause()
            player.replaceCurrentItem(with: nil)
            isPlaying = false
        } else if isPlaying == false {
            print("Playing...")
            player.play()
            isPlaying = true
        }
    }
    
    @IBAction func itunesLinkTapped(_ sender: UIButton) {
        print("iTunes link tapped...")
        //Handle button press within a Cell
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        if let url = NSURL(string: songs[(indexPath?.row)!].itunesLink) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Prevent row from highlighting when clicked
        tableView.allowsSelection = false
        
        //Cell separator styling
        tableView.separatorColor = UIColor.black
        tableView.separatorInset = .init(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        
        //Status bar styling
        view.backgroundColor = GradientColor(.leftToRight, frame: view.frame, colors: [UIColor.gray, UIColor.white, UIColor.gray])
        
        //Color behind the tableview
        tableView.backgroundColor = GradientColor(.leftToRight, frame: view.frame, colors: [UIColor.gray, UIColor.white, UIColor.gray])
        
        //Searchbar styling
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        //Add refresh control to tableview
        refreshControl.addTarget(nil, action: #selector(didRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        //Refresh control styling
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Artists...")
        refreshControl.tintColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View Did Appear!")
        loadWithSpinners()
    }
    
    func loadWithSpinners() {
        SwiftSpinner.show("Gathering Song Data...")
        
        SongData().getSongData { (songs) in
            self.songs = songs
            self.tableView.reloadData()
            
            if songs.count == 0 {
                SwiftSpinner.show("No Songs Found...", animated: false).addTapHandler({
                    SwiftSpinner.hide()
                }, subtitle: "Tap to dismiss...")
            } else if songs.count > 0 {
                SwiftSpinner.hide()
            }
        }
    }
    
    @objc func didRefresh() {
        print("Refreshing table...")
        SongData().getSongData { (songs) in
            self.songs = songs
            self.tableView.reloadData()
        }
        refreshControl.endRefreshing()
    }
    
}

//MARK: - DataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DataCell
        
        //Make cells transparent
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        //Access specific song from array
        let song = songs[indexPath.row]
        cell.artistLabel.text = song.artistName
        cell.songLabel.text = song.songName
        cell.itunesRanking.text = "🏅 \(song.itunesRanking)"
        
        //User kingfisher to set album Image on button
        let btnUrl = URL(string: song.imageURL)
        cell.albumImgBtn.kf.setBackgroundImage(with: btnUrl, for: .normal, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        
        return cell
    }
    
    
}

//MARK: - Delegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Initial cell state
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        cell.layer.transform = transform
        
        //change cell to final state
        UIView.animate(withDuration: 0.50) {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Searching...")
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        
        searchItem = searchBar.text!
        loadWithSpinners()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.endEditing(true)
    }
}

