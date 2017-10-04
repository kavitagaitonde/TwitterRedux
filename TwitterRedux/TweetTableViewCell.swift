//
//  TweetTableViewCell.swift
//  TwitterTwo
//
//  Created by Kavita Gaitonde on 9/25/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TweetTableViewCell: UITableViewCell, TTTAttributedLabelDelegate{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: TTTAttributedLabel!
    @IBOutlet weak var activityTimestampLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!    
    @IBOutlet weak var favoriteCountLabel: UILabel!
    var updateTweet : (Tweet) -> Void = { (tweet: Tweet) in }
    var tweet: Tweet?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = 5.0
        self.profileImageView.clipsToBounds = true
        self.tweetTextLabel.enabledTextCheckingTypes =  NSTextCheckingAllTypes
        self.tweetTextLabel.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func prepareCellFor(tweet: Tweet, indexPath: IndexPath) {
        self.tweet = tweet
        self.tweetTextLabel?.text = tweet.text
        self.nameLabel?.text = tweet.user?.name
        self.screenNameLabel?.text = "@\((tweet.user?.screenName)!)"
        self.activityTimestampLabel?.text = tweet.getElapsedTimeString()
        self.retweetCountLabel?.text = "\(tweet.retweetCount)"
        self.favoriteCountLabel?.text = "\(tweet.favoriteCount)"
        self.replyButton.tag = indexPath.row
        
        if (tweet.user?.profileUrl != nil) {
            self.profileImageView.setImageWith((tweet.user?.profileUrl!)!)
        } else {
            self.profileImageView.image = nil
        }
        if tweet.favorited {
            self.favoriteButton.isSelected = true
        } else {
            self.favoriteButton.isSelected = false
        }
        if tweet.retweeted {
            self.retweetButton.isSelected = true
        } else {
            self.retweetButton.isSelected = false
        }
        if tweet.retweetedByUser != nil {
            if User.currentUser?.id == tweet.retweetedByUser?.id {
                self.retweetLabel.text = "You Retweeted"
            } else {
                self.retweetLabel.text = "\((tweet.retweetedByUser?.name)!) Retweeted"
            }
            self.retweetLabel.isHidden = false
            self.retweetImageView.isHidden = false
        } else {
            self.retweetLabel.isHidden = true
            self.retweetImageView.isHidden = true
        }
    }
    
    @IBAction func retweetClicked(_ sender: Any) {
        if(tweet?.retweeted)! {
            TwitterClient.sharedInstance?.unretweet(tweetId: (tweet?.id)!, success: {(tweet: Tweet) -> () in
                print ("success unfavoriting")
                self.updateTweet(tweet)
            }, failure: { (error: Error) in
                print ("error unfavoriting")
            })
        } else {
            TwitterClient.sharedInstance?.retweet(tweetId: (tweet?.id)!, success: {(tweet: Tweet) -> () in
                print ("success retweeting")
                self.updateTweet(tweet)
            }, failure: { (error: Error) in
                print ("error retweeting")
            })
        }
    }
    
    @IBAction func favoriteClicked(_ sender: Any) {
        if(tweet?.favorited)! {
            TwitterClient.sharedInstance?.unFavorite(tweetId: (tweet?.id)!, success: {(tweet: Tweet) -> () in
                print ("success unfavoriting")
                self.updateTweet(tweet)
            }, failure: { (error: Error) in
                print ("error unfavoriting")
            })
        } else {
            TwitterClient.sharedInstance?.favorite(tweetId: (tweet?.id)!, success: {(tweet: Tweet) -> () in
                print ("success favoriting")
                self.updateTweet(tweet)
            }, failure: { (error: Error) in
                print ("error favoriting")
            })
        }
        
    }
    
    // MARK: - TTTAttributedLabel
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
        if let url = URL(string: "tel://\(phoneNumber!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}
