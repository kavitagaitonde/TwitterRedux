//
//  ComposeViewController.swift
//  TwitterTwo
//
//  Created by Kavita Gaitonde on 9/25/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

enum ComposeMode: Int {
    case tweet = 0, reply
}

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tweetTextView: UITextView!
    
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var replyLabel: UILabel!
    
    @IBOutlet weak var quotesTextView: UITextView!
    
    var addTweet : (Tweet) -> Void = { (tweet: Tweet) in }
    var composeMode = ComposeMode.tweet
    var replyToTweet: Tweet?
    var isPlaceholderText: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var user: User?
        
        if self.composeMode == .tweet {
            user = User.currentUser
            self.tweetTextView.text = "What's on your mind today?"
            self.nameLabel.isHidden = false
            self.screenNameLabel.isHidden = false
            self.replyLabel.isHidden = true
            self.characterCountLabel.text = "140"
            self.quotesTextView.isHidden = false
        } else {
            user = replyToTweet?.user
            self.tweetTextView.text = "@\((user?.screenName)! )"
            self.nameLabel.isHidden = true
            self.screenNameLabel.isHidden = true
            self.replyLabel.isHidden = false
            self.isPlaceholderText = false
            self.characterCountLabel.text = "\(getRemainingCharsCount())"
            self.quotesTextView.isHidden = true
        }
        self.profileImageView.layer.cornerRadius = 5.0
        self.profileImageView.clipsToBounds = true
        if (user?.profileUrl != nil) {
            self.profileImageView.setImageWith((user?.profileUrl!)!)
        } else {
            self.profileImageView.image = nil
        }
        self.nameLabel.text = user?.name
        self.screenNameLabel.text = "@\((user?.screenName)!)"
        self.replyLabel.text = "In reply to \((user?.name)!)"
        self.tweetTextView.textColor = UIColor.lightGray
        self.tweetTextView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TextView Delegate
    
    func textViewDidBeginEditing(_: UITextView) {
        if self.isPlaceholderText {
            self.tweetTextView.text = nil
            self.tweetTextView.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.tweetTextView.text.isEmpty {
            //self.tweetTextView.text = "What would you like to tweet today?"
            self.tweetTextView.textColor = UIColor.lightGray
            self.isPlaceholderText = true
        }
    }
    
    func getRemainingCharsCount() -> Int {
        let count = self.tweetTextView.text.characters.count
        return 140 - count
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.isPlaceholderText = false
        let count = self.tweetTextView.text.characters.count
        self.characterCountLabel.text = "\(getRemainingCharsCount())"
        if (count >= 140) {
            return false
        } else {            
            return true
        }
    }
    
    /*func textViewDidChange(_: UITextView) {
        let count = self.tweetTextView.text.characters.count
        if (count >= 140) {
            self.te
        } else {
            self.characterCountLabel.text = "\(140 - count)"
        }
        
    }*/


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClose(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onTweet(_ sender: AnyObject) {
        if((self.tweetTextView.text != nil) && self.tweetTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0){
            if composeMode == .tweet {
                TwitterClient.sharedInstance?.tweet(text: self.tweetTextView.text, success: {(tweet: Tweet) -> () in
                    
                    let addedTweet = tweet
                    //success sending message
                    let alertController = UIAlertController(title: "Tweet", message: "Tweet sent successfully. Click Untweet to delete this tweet or OK to continue", preferredStyle: .actionSheet)
                    // OK
                    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action:UIAlertAction!) in
                        print ("OK")
                        self.addTweet(addedTweet)
                        self.onClose(sender)
                    })
                    alertController.addAction(okAction)
                    
                    // Untweet
                    let untweetAction = UIAlertAction(title: "Untweet", style: .destructive, handler: { (action:UIAlertAction!) in
                        print ("Untweet id = \(tweet.id)")
                        TwitterClient.sharedInstance?.untweet(tweetId: tweet.id, success: {(tweet: Tweet) -> () in
                            print ("success untweeting")
                            self.onClose(sender)
                        }, failure: { (error: Error) in
                            print ("error untweeting")
                            self.addTweet(addedTweet)
                            self.onClose(sender)
                        })
                    })
                    alertController.addAction(untweetAction)
                    
                    // Present Alert
                    self.present(alertController, animated: true, completion:nil)
                    
                    
                }, failure: { (error: Error) in
                    //error sending message
                    let alertController = UIAlertController(title: "Tweet", message: "We are unable to post the tweet right now.", preferredStyle: .actionSheet)
                    // OK
                    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action:UIAlertAction!) in
                        print ("OK")
                    })
                    alertController.addAction(okAction)
                    
                    // Present Alert
                    self.present(alertController, animated: true, completion:nil)
                })
            } else {
                TwitterClient.sharedInstance?.reply(text: self.tweetTextView.text, toTweetId: (replyToTweet?.id)!, success: {(tweet: Tweet) -> () in
                    print ("success replying to tweet")
                    self.addTweet(tweet)
                    self.onClose(sender)
                }, failure: { (error: Error) in
                    print ("error replying to tweet")
                    self.onClose(sender)
                })
            }
        } else {
            //nothing entered.
            let alertController = UIAlertController(title: "Tweet", message: "Please write a message",
                                                    preferredStyle: .actionSheet)
            // OK
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action:UIAlertAction!) in
                                                print ("OK")
            })
            alertController.addAction(okAction)
            
            // Present Alert
            self.present(alertController, animated: true, completion:nil)
        }
        
        
    }
    
}
