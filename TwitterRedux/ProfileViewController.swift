//
//  ProfileViewController.swift
//  TwitterRedux
//
//  Created by Kavita Gaitonde on 10/4/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl : UIRefreshControl?
    var infiniteScrollActivityView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var tweets: [Tweet] = [Tweet]()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 125
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 80
        
        let tableHeaderView = ProfileHeaderView(frame: CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: 307))
        tableHeaderView.nameLabel.text = user?.name
        tableHeaderView.screennameLabel.text = "@\((user?.screenName)!)"
        tableHeaderView.descriptionLabel.text = "\((user?.desc)!)"
        //tableHeaderView.createdDateLabel.text = "Joined on \((user?.createdAt)!)"
        tableHeaderView.followersCountLabel.text = "\((user?.followersCount)!)"
        tableHeaderView.followingCountLabel.text = "\((user?.followingCount)!)"
        //tableHeaderView.favoritesCountLabel.text = "\((user?.favoritesCount)!)"
        tableHeaderView.tweetsCountLabel.text = "\((user?.tweetsCount)!)"
        if (user?.profileUrl != nil) {
            tableHeaderView.profileImageView.setImageWith((user?.profileUrl!)!)
        } else {
            tableHeaderView.profileImageView.image = nil
        }
        if (user?.bannerUrl != nil) {
            tableHeaderView.bannerImageView.setImageWith((user?.bannerUrl!)!)
        } else {
            tableHeaderView.bannerImageView.image = nil
        }
        self.tableView.tableHeaderView = tableHeaderView
        
        // Add UI refreshing on pull down
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        self.tableView.insertSubview(self.refreshControl!, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        infiniteScrollActivityView = InfiniteScrollActivityView(frame: frame)
        infiniteScrollActivityView!.isHidden = true
        self.tableView.addSubview(infiniteScrollActivityView!)
        
        var insets = self.tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight + 50
        self.tableView.contentInset = insets
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadData(true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        self.loadData(true)
    }

    
    func loadData(_ recent: Bool) {
        MBProgressHUD.hide(for: self.view, animated: true)
        self.infiniteScrollActivityView!.stopAnimating()
        self.refreshControl!.endRefreshing()
        
        
        let success = {(tweets: [Tweet]) in
            print ("Tweets fetch successful")
            if(recent) {//fetch latest tweets
                self.tweets = tweets
            } else {
                self.tweets += tweets
            }
            
            self.tableView.reloadData()
            self.isMoreDataLoading = false
        }
        
        let failure = { (error: Error?) in
            print("Error in fetching tweets")
            self.isMoreDataLoading = false
        }
        
        if(recent) {//fetch latest tweets, this will overwrite the existing tweets array
            TwitterClient.sharedInstance?.getTimeLine(forUser: user, forType: .user, success: success, failure: failure)
        } else { //older tweets
            TwitterClient.sharedInstance?.getTimeLine(forUser: user, forType: .user, beforeId: (self.tweets.count > 0) ? self.tweets[self.tweets.count-1].id:0, success: success, failure: failure)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("****** Total rows = \(self.tweets.count)")
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTweetCell", for: indexPath) //as! TweetTableViewCell
        let tweet = self.tweets[indexPath.row] as Tweet
        /*cell.prepareCellFor(tweet: tweet, indexPath: indexPath)
        cell.viewController = self
        cell.updateTweet = { (updatedTweet: Tweet) in
            self.tweets[indexPath.row] = updatedTweet
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }*/
        cell.textLabel?.text = "\(tweet.text)"
        return cell
    }
    
    

    
    // MARK: - Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "profileComposeSegue") {
            let composeController = segue.destination as! ComposeViewController
            composeController.composeMode = .tweet
            composeController.addTweet = { (tweet: Tweet) in
            }
        }
    }
 
}
