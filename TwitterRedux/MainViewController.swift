//
//  MainViewController.swift
//  TwitterTwo
//
//  Created by Kavita Gaitonde on 9/25/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit
import MBProgressHUD

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl : UIRefreshControl?
    var infiniteScrollActivityView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var tweets: [Tweet] = [Tweet]()
    var tweetRecentId = 0
    var tweetOldestId = 0
    //var tweetOffset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("******* Loading MainViewController *******")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 125
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.scrollsToTop = true
        
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
                /*if(self.tweetRecentId > 0) {
                    self.tweets = tweets + self.tweets
                } else {*/
                    self.tweets = tweets
                //}
            } else {
                self.tweets += tweets
            }
            if(self.tweets.count > 0) {
                self.tweetRecentId = self.tweets[0].id
                self.tweetOldestId = self.tweets[self.tweets.count-1].id
            } else {
                self.tweetRecentId = 0
                self.tweetOldestId = 0
            }
            self.tableView.reloadData()
            self.isMoreDataLoading = false
        }
        
        let failure = { (error: Error?) in
            print("Error in fetching tweets")
            self.isMoreDataLoading = false
        }
        
        if(recent) {//fetch latest tweets
            /*if(self.tweetRecentId > 0) {
                TwitterClient.sharedInstance?.homeTimeLine(afterId: self.tweetRecentId, success: success, failure: failure)
            } else {*/
                TwitterClient.sharedInstance?.homeTimeLine(success: success, failure: failure)
            //}
        } else { //older tweets
            TwitterClient.sharedInstance?.homeTimeLine(beforeId: self.tweetOldestId, success: success, failure: failure)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("****** Total rows = \(self.tweets.count)")
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as! TweetTableViewCell
        let tweet = self.tweets[indexPath.row] as Tweet
        cell.prepareCellFor(tweet: tweet, indexPath: indexPath)
        cell.updateTweet = { (updatedTweet: Tweet) in
            self.tweets[indexPath.row] = updatedTweet
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }

    // MARK: - Scrollview
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!self.isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            //actual hieght of the table filled in with content - height of 1 page of content
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
                self.isMoreDataLoading = true
                print("Loading more data from oldest offset = \(self.tweetOldestId)")
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                infiniteScrollActivityView?.frame = frame
                infiniteScrollActivityView!.startAnimating()
                
                self.loadData(false)
            }
            
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if(segue.identifier == "composeTweetSegue") {
                let composeController = segue.destination as! ComposeViewController
                composeController.composeMode = .tweet
                composeController.addTweet = { (tweet: Tweet) in
                    self.tweets.insert(tweet, at: 0)
                    self.tweetRecentId = self.tweets[0].id
                    self.tableView.reloadData()
                }
            } else if(segue.identifier == "composeReplySegue") {
                let composeController = segue.destination as! ComposeViewController
                composeController.composeMode = .reply
                let button = sender as! UIButton
                composeController.replyToTweet = self.tweets[button.tag]
                composeController.addTweet = { (tweet: Tweet) in
                    self.tweets.insert(tweet, at: 0)
                    self.tweetRecentId = self.tweets[0].id
                    self.tableView.reloadData()
                }
            } else if (segue.identifier == "tweetDetailSegue") {
                let cell = sender as! TweetTableViewCell
                if let indexPath = self.tableView.indexPath(for: cell) {
                    let detailsController = segue.destination as! DetailViewController
                    let tweet = self.tweets[indexPath.row] as Tweet
                    detailsController.tweet = tweet
                    detailsController.updateTweet = { (updatedTweet: Tweet) in
                        self.tweets[indexPath.row] = updatedTweet
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            } else if (segue.identifier == "meSegue") {
                //try to get the latest user object
                TwitterClient.sharedInstance?.userCredentials(success: {(user: User) in
                    User.currentUser = user
                }, failure: {(error: Error?) in
                    //do nothing, use the existing instance
                })
            }
    
    }
 

    
    @IBAction func onLogout(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.logout()
    }
    
}
