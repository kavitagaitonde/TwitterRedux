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
    var timelineType: TimelineType = TimelineType.home
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("******* Loading MainViewController *******")
        if user == nil {
            user = User.currentUser
        }
        
        print(self.navigationController?.viewControllers)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 125
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.scrollsToTop = true
        
        //setup cell nib
        self.tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetTableViewCell")
        
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
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ReloadView"), object: nil, queue: OperationQueue.main, using: {(Notification) -> () in
            print ("****** RELOADING DATA *************")
            self.user = User.currentUser
            self.loadData(true)
        })
        

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
            TwitterClient.sharedInstance?.getTimeLine(forUser: user, forType: timelineType, success: success, failure: failure)
        } else { //older tweets
            TwitterClient.sharedInstance?.getTimeLine(forUser: user, forType: timelineType, beforeId: (self.tweets.count > 0) ? self.tweets[self.tweets.count-1].id:0, success: success, failure: failure)
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
        cell.viewController = self
        cell.updateTweet = { (updatedTweet: Tweet) in
            self.tweets[indexPath.row] = updatedTweet
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.replyTweet = { () in
            self.performSegue(withIdentifier: "replySegue", sender: tweet)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TweetTableViewCell {
            performSegue(withIdentifier: "tweetDetailSegue", sender: cell)
        }
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
                print("Loading more data from oldest offset = \((self.tweets.count > 0) ? self.tweets[self.tweets.count-1].id:0)")
                
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
                    self.tableView.reloadData()
                }
            } else if(segue.identifier == "replySegue") {
                let composeController = segue.destination as! ComposeViewController
                composeController.composeMode = .reply
                let tweet = sender as! Tweet
                composeController.replyToTweet = tweet
                composeController.addTweet = { (tweet: Tweet) in
                    self.tweets.insert(tweet, at: 0)
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
            }
    
    }
 

    
    @IBAction func onLogout(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.logout()
    }
    
}
