//
//  customRowForPosts.swift
//  Community
//
//  Created by Naseem Raad on 4/29/18.
//  Copyright © 2018 HonestSarcasm. All rights reserved.
//

import UIKit

class customRowForPosts: UITableViewCell {
    
    var values:NSArray = []
    
    func getData() {
        let url = NSURL(string: "http://206.189.174.163/getPosts.php?city=\(city)")
        let data = NSData(contentsOf: url! as URL)
        values = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
    }

    @IBOutlet weak var profileID: UILabel!
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var profileContent: UILabel!
    @IBOutlet weak var profileKarma: UILabel!
    @IBOutlet weak var upvoteButtonOutlet: UIButton!
    @IBOutlet weak var downvoteButtonOutlet: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func upvoteButtonAction(_ sender: UIButton) {
        getData()
        upvoteButtonOutlet.setImage(UIImage(named: "upvote_off.png"), for: .disabled)
        upvoteButtonOutlet.isEnabled = false
        downvoteButtonOutlet.isEnabled = true
        profileKarma.text? = String(profileKarma.tag+1)
        let mainData = values[upvoteButtonOutlet.tag] as? [String:Any]
        upvotedPosts.append(mainData?["post_id"] as! String)
        UserDefaults.standard.set(upvotedPosts, forKey: "upvotedPosts")
        sendUpvote(postID: mainData?["post_id"] as! String)
    }
    @IBAction func downvoteButtonAction(_ sender: UIButton) {
        getData()
        downvoteButtonOutlet.setImage(UIImage(named: "downvote_off.png"), for: .disabled)
        downvoteButtonOutlet.isEnabled = false
        upvoteButtonOutlet.isEnabled = true
        profileKarma.text? = String(profileKarma.tag-1)
        let mainData = values[downvoteButtonOutlet.tag] as? [String:Any]
        downvotedPosts.append(mainData?["post_id"] as! String)
        UserDefaults.standard.set(downvotedPosts, forKey: "downvotedPosts")
        sendDownvote(postID: mainData?["post_id"] as! String)
    }
    
    func sendUpvote(postID: String) {
        let headers = [
            "Cache-Control": "no-cache",
            ]
        
        let url = "http://206.189.174.163/upvoteAPost.php?post_id=" + postID
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse)
            }
        })
        
        dataTask.resume()
    }
    
    func sendDownvote(postID: String) {
        let headers = [
            "Cache-Control": "no-cache",
            ]
        
        let url = "http://206.189.174.163/downvoteAPost.php?post_id=" + postID
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse)
            }
        })
        
        dataTask.resume()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
