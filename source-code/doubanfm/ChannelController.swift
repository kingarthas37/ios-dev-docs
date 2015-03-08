//
//  ChannelController.swift
//  doubanfm
//
//  Created by 刘松坡 on 14/10/28.
//  Copyright (c) 2014年 刘松坡. All rights reserved.
//

import UIKit

class ChannelController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    var channelData = NSArray()
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channelData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        var name = channelData[indexPath.row]["name"] as String
        cell.textLabel?.text = name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.addObserver(channelData[indexPath.row]["name"] as String, forKeyPath: "channelId", options: NSKeyValueObservingOptions.New, context: nil)
        self.appDelegate.channelId = channelData[indexPath.row]["channel_id"] as String?
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
