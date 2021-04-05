//
//  Compose.swift
//  Community
//
//  Created by Naseem Raad on 4/30/18.
//  Copyright © 2018 HonestSarcasm. All rights reserved.
//

import UIKit
import Foundation

class Compose: UIViewController, UITextViewDelegate {
    
    var user_id : String = ""

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var characterCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!]

        
        
        
    }
    
    @IBAction func Post(_ sender: UIBarButtonItem) {
        
        getUniqueUsername()
        
        print(user_id)
        
        if(textView.text == ""){

        }else{

            let request = NSMutableURLRequest(url : NSURL(string : "http://206.189.174.163/publishAPost.php")! as URL)

            request.httpMethod = "POST"

            let postString = "postContent=\(textView.text!)&user_id=\(user_id)&city=\(city)"
            
            print(postString)

            request.httpBody = postString.data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in

                if error != nil {
                    print("error=\(error!)")
                    return
                }

                print("response = \(response!)")

                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("responseString = \(responseString!)")

                DispatchQueue.main.async() {
                    postsThatIHaveCommentedOn[self.user_id] = self.user_id
                    UserDefaults.standard.set(postsThatIHaveCommentedOn, forKey: "postsThatIHaveCommentedOn")
                    myPosts.append(self.user_id)
                    UserDefaults.standard.set(myPosts, forKey: "myPosts")
                    let goToHomePage = self.storyboard?.instantiateViewController(withIdentifier: "HomePage")
                    self.present(goToHomePage!, animated: true, completion: nil)
                }
            }
            task.resume()

        }
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if(140-newText.count > 0){
            characterCount.text = String(140-newText.count)
        }else{
            characterCount.text = String(0)
        }
        
        return newText.count <= 140
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
    
    @IBAction func cancelPost(_ sender: UIBarButtonItem) {
        let goToHomePage = self.storyboard?.instantiateViewController(withIdentifier: "HomePage")
        self.present(goToHomePage!, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


