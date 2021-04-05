//
//  CommentView.swift
//  Community
//
//  Created by Naseem Raad on 4/27/18.
//  Copyright © 2018 HonestSarcasm. All rights reserved.
//

import UIKit
import Foundation


class CommentView: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var user_id = "";
    
    var tempUsernameArray : [String:String] = [:]
    
    var username = "";
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var commentViewTable: UITableView!
    
    @IBAction func returnHome(_ sender: UIBarButtonItem) {
        let goToHomePage = self.storyboard?.instantiateViewController(withIdentifier: "HomePage")
        self.present(goToHomePage!, animated: true, completion: nil)
        
    }
    
    var post = [String:Any]()
    var commentArray : [Any] = []
    
    @objc func reloadData(_ sender: Any) {
        getData()
        refreshControl.endRefreshing()
        commentViewTable.reloadData()
    }
    
    func getData() {
        var values1:NSArray = []
        var values2:NSArray = []
        
        post = [String:Any]()
        commentArray = []
        let url = NSURL(string: "http://206.189.174.163/getCommentsForPost.php?post_id=\(postClicked)")
        let data = NSData(contentsOf: url! as URL)
        values1 = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        let url2 = NSURL(string: "http://206.189.174.163/getAPost.php?post_id=\(postClicked)")
        let data2 = NSData(contentsOf: url2! as URL)
        values2 = try! JSONSerialization.jsonObject(with: data2! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        
        if(values1.count == 0){
            
        }else{
            for i in 0...(values1.count-1) {
                let mainData = values1[i] as? [String:Any]
                
                commentArray.append(mainData!)
            }
        }
        
        post = values2[0] as! [String : Any]
        commentViewTable.reloadData()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        
        commentViewTable.insertSubview(refreshControl, at: 0)
        
        refreshControl.addTarget(self, action: #selector(reloadData(_:)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.8862745098, green: 0.3294117647, blue: 0.3529411765, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...")
        getData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return 1
        case 1:
            return commentArray.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return ""
        case 1:
            return "Comments"
        default:
            return "You have encountered Error"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! customRowForPosts
            cell.profileUsername.text = "OP"
            cell.profileIcon.image = UIImage(named: "OP")
            
            let dateRangeStart = Date()
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            fmt.timeZone = NSTimeZone(name: "UTC") as! TimeZone
            let dateRangeEnd = fmt.date(from:(post["date"] as! String))
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateRangeEnd!, to: dateRangeStart)
            if(components.month! > 0){
                cell.timeLabel.text = String(components.month!) + " month"
            }else if(components.day! > 0){
                cell.timeLabel.text = String(components.day!) + " d"
                
            }else if(components.hour! > 0){
                cell.timeLabel.text = String(components.hour!) + " h"
                
            }else if(components.minute! > 0){
                cell.timeLabel.text = String(components.minute!) + " m"
            }else{
                cell.timeLabel.text = String(components.second!) + " s"
            }
            
            
            cell.profileContent?.text = post["post_content"] as! String
            cell.profileKarma?.text = post["post_rating"] as! String
            if(upvotedPosts.contains((post["post_id"]as? String)!) == true){
                cell.upvoteButtonOutlet.setImage(UIImage(named: "upvote_off.png"), for: .disabled)
                cell.downvoteButtonOutlet.isEnabled = true
                cell.upvoteButtonOutlet.isEnabled = false
            }
            if(downvotedPosts.contains((post["post_id"] as? String)!) == true){
                cell.downvoteButtonOutlet.setImage(UIImage(named: "downvote_off.png"), for: .disabled)
                cell.downvoteButtonOutlet.isEnabled = false
                cell.upvoteButtonOutlet.isEnabled = true
            }
            tempUsernameArray[(post["post_id"]as? String)!] = "OP"
            cell.upvoteButtonOutlet.tag = indexPath.row
            cell.downvoteButtonOutlet.tag = indexPath.row
             return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment") as! customRowForComments
            
            let dateRangeStart = Date()
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            fmt.timeZone = NSTimeZone(name: "UTC") as! TimeZone
            let dateRangeEnd = fmt.date(from:((commentArray[indexPath.row] as! [String:Any])["date"] as! String))
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateRangeEnd!, to: dateRangeStart)
            if(components.month! > 0){
                cell.timeLabel.text = String(components.month!) + " month"
            }else if(components.day! > 0){
                cell.timeLabel.text = String(components.day!) + " d"
                
            }else if(components.hour! > 0){
                cell.timeLabel.text = String(components.hour!) + " h"
                
            }else if(components.minute! > 0){
                cell.timeLabel.text = String(components.minute!) + " m"
            }else{
                cell.timeLabel.text = String(components.second!) + " s"
            }
            
            
                if(tempUsernameArray[(commentArray[indexPath.row] as! [String:Any])["user_id"] as! String] == nil){
                    var tempUsername = adjectives[Int(arc4random_uniform(UInt32(adjectives.count)))] + lastName[Int(arc4random_uniform(UInt32(lastName.count)))]
                    while((tempUsernameArray.values).contains(tempUsername)){
                        tempUsername = adjectives[Int(arc4random_uniform(UInt32(adjectives.count)))] + lastName[Int(arc4random_uniform(UInt32(lastName.count)))]
                    }
                    tempUsernameArray[(commentArray[indexPath.row] as! [String:Any])["user_id"] as! String] = tempUsername
                }
                cell.profileUsername.text = tempUsernameArray[(commentArray[indexPath.row] as! [String:Any])["user_id"] as! String]!
                cell.profileIcon.image = UIImage(named: "standing-up-man--\(arc4random_uniform(15)+1)")
            cell.profileID?.text = (commentArray[indexPath.row] as! [String:Any])["comment_id"] as! String;
            cell.profileContent?.text = (commentArray[indexPath.row] as! [String:Any])["comment_content"] as! String
            cell.profileKarma?.text = (commentArray[indexPath.row] as! [String:Any])["comment_rating"] as! String
            if(upvotedComments.contains(((commentArray[indexPath.row] as! [String:Any])["comment_id"] as! String as? String)!) == true){
                cell.upvoteButtonOutlet.setImage(UIImage(named: "upvote_off.png"), for: .disabled)
                cell.downvoteButtonOutlet.isEnabled = true
                cell.upvoteButtonOutlet.isEnabled = false
            }
            if(downvotedComments.contains(((commentArray[indexPath.row] as! [String:Any])["comment_id"] as! String as? String)!) == true){
                cell.downvoteButtonOutlet.setImage(UIImage(named: "downvote_off.png"), for: .disabled)
                cell.downvoteButtonOutlet.isEnabled = false
                cell.upvoteButtonOutlet.isEnabled = true
            }
            cell.upvoteButtonOutlet.tag = indexPath.row
            cell.downvoteButtonOutlet.tag = indexPath.row
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! customRowForPosts
            cell.profileContent?.text = "You have encountered an Error"
            return cell
        }
    }
    
    @IBOutlet weak var commentField: UITextField!
    
    @IBAction func postAComment(_ sender: UIButton) {
        let request = NSMutableURLRequest(url : NSURL(string : "http://206.189.174.163/addComment.php")! as URL)
        
        request.httpMethod = "POST"
        
        if((postsThatIHaveCommentedOn[(post["post_id"]as? String)!]) != nil){
            user_id = postsThatIHaveCommentedOn[(post["post_id"]as? String)!]!
        }else{
            getUniqueUsername()
            postsThatIHaveCommentedOn[(post["post_id"]as? String)!] = self.user_id
            UserDefaults.standard.set(postsThatIHaveCommentedOn, forKey: "postsThatIHaveCommentedOn")
        }
        
        let postString = "commentContent=\(commentField.text!)&user_id=\(user_id)&post_id=\((post["post_id"]as? String)!)"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            DispatchQueue.main.async() {
                self.getData()
                self.commentField.text = ""
//                let goToHomePage = self.storyboard?.instantiateViewController(withIdentifier: "HomePage")
//                self.present(goToHomePage!, animated: true, completion: nil)
            }
        }
        task.resume()
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -270, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -270, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUniqueUsername() {
        let url = NSURL(string: "http://206.189.174.163/getUniqueUsername.php")
        let data = NSData(contentsOf: url! as URL)
        var temp = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        user_id = (temp[0] as? String)!
    }

}
