//
//  ViewController.swift
//  doubanfm
//
//  Created by 刘松坡 on 14/10/27.
//  Copyright (c) 2014年 刘松坡. All rights reserved.
//

import UIKit
import MediaPlayer

class SongController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var playtime: UILabel!
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var currentChannelId: String! = "0"
    var songData = NSArray()
    var channelData = NSArray()
    var imageCache = Dictionary<String, UIImage>()
    
    var mediaPlayer = MPMoviePlayerController()
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadSong(currentChannelId)
        loadChannels()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (appDelegate.channelId != nil) {
            currentChannelId = appDelegate.channelId
            loadSong(currentChannelId)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songData.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "song")
        let rowData: NSDictionary = self.songData[indexPath.row] as NSDictionary
        
        var imageUrl: String! = rowData["picture"] as String
        var title: String! = rowData["title"] as? String
        var artist: String! = rowData["artist"] as String
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = artist
        
        let cacheImage = imageCache[title]
        
        if cacheImage == nil {
            var url: NSURL! = NSURL(string: imageUrl)
            var request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                self.imageCache[title] = UIImage(data: data)
            }
        }
        cell.imageView?.image = cacheImage
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pictureUrl = self.songData[indexPath.row]["picture"] as String
        let songUrl = self.songData[indexPath.row]["url"] as String

        loadImage(pictureUrl)
        playSong(songUrl)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var cc = segue.destinationViewController as ChannelController
        cc.channelData = self.channelData
    }
    
    func loadSong(channelId: String){
        var url: NSURL! = NSURL(string: "http://douban.fm/j/mine/playlist?channel=\(channelId)")
        var request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            let result: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            if (result["song"] != nil){
                self.songData = result["song"] as NSArray
                self.table.reloadData()
                
                let pictureUrl = self.songData[0]["picture"] as String
                let songUrl = self.songData[0]["url"] as String
                
                self.loadImage(pictureUrl)
                self.playSong(songUrl)
            }
        }
    }
    
    func loadImage(imageUrl: String){
        var url: NSURL! = NSURL(string: imageUrl)
        var request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            self.image.image = UIImage(data: data)
        }
    }
    
    func playSong(songUrl: String){
        self.timer.invalidate()
        self.playtime.text = "00:00"
        self.progressbar.setProgress(0.0, animated: true)
        self.mediaPlayer.stop()
        self.mediaPlayer.contentURL = NSURL(string: songUrl)
        self.mediaPlayer.play()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "resetPlayTimeAndProgressBar", userInfo: nil, repeats: true)
    }
    
    func resetPlayTimeAndProgressBar(){
        let countTime = self.mediaPlayer.currentPlaybackTime

        if countTime > 0 {
            let duration = self.mediaPlayer.duration
            let progressValue = CFloat(countTime/duration)
            progressbar.setProgress(progressValue, animated: true)
            
            var countSecends: Int = Int(countTime)
            var minutes: Int = Int(countSecends / 60)
            var secends: Int = countSecends % 60
            
            var pTime = ""
            if minutes < 10 {
                pTime += "0\(minutes):"
            } else {
                pTime += "\(minutes)"
            }
            
            if secends < 10 {
                pTime += "0\(secends)"
            } else {
                pTime += "\(secends)"
            }
            
            self.playtime.text = pTime
        }
    }
    
    func loadChannels(){
        var url: NSURL! = NSURL(string: "http://www.douban.com/j/app/radio/channels")
        var request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            var result: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            if result["channels"] != nil {
                self.channelData = result["channels"] as NSArray
                self.table.reloadData()
            }
        }
    }
    
}

