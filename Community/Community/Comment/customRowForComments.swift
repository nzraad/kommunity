//
//  customRow.swift
//  Community
//
//  Created by Naseem Raad on 4/27/18.
//  Copyright © 2018 HonestSarcasm. All rights reserved.
//

// TODO:
// Add Logic if someone upvotes and then downvotes
//
//
//
//
//
//


import UIKit
import Foundation

class customRowForComments: UITableViewCell {
    
    @IBOutlet weak var profileID: UILabel!
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var profileContent: UILabel!
    @IBOutlet weak var profileKarma: UILabel!
    @IBOutlet weak var upvoteButtonOutlet: UIButton!
    
    @IBOutlet weak var downvoteButtonOutlet: UIButton!

    @IBOutlet weak var timeLabel: UILabel!
    @IBAction func upvoteButtonAction(_ sender: UIButton) {
        upvoteButtonOutlet.setImage(UIImage(named: "upvote_off.png"), for: .disabled)
        upvoteButtonOutlet.isEnabled = false
        downvoteButtonOutlet.isEnabled = true
        profileKarma.text? = String(profileKarma.tag+1)
        upvotedComments.append(profileID.text!)
        UserDefaults.standard.set(upvotedComments, forKey: "upvotedComments")
        sendUpvote(postID: profileID.text!)
    }
    
    @IBAction func downvoteButtonAction(_ sender: UIButton) {
        downvoteButtonOutlet.setImage(UIImage(named: "downvote_off.png"), for: .disabled)
        downvoteButtonOutlet.isEnabled = false
        upvoteButtonOutlet.isEnabled = true
        profileKarma.text? = String(profileKarma.tag-1)
        downvotedComments.append(profileID.text!)
        UserDefaults.standard.set(downvotedComments, forKey: "downvotedComments")
        sendDownvote(postID: profileID.text!)
        
    }
    func sendUpvote(postID: String) {
        let headers = [
            "Cache-Control": "no-cache",
        ]
        
        let url = "http://206.189.174.163/upvoteAComment.php?comment_id=" + postID
        
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
                print(httpResponse)
            }
        })
        
        dataTask.resume()
    }
    
    func sendDownvote(postID: String) {
        let headers = [
            "Cache-Control": "no-cache",
            ]

        let url = "http://206.189.174.163/downvoteAComment.php?comment_id=" + postID
        
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
                print(httpResponse)
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
