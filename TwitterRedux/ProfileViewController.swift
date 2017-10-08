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
    var origBannerImageHeightConstraintValue: CGFloat = 0.0
    var shouldUpdateConstraints: Bool = false
    var prevScrollOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 125
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let tableHeaderView = ProfileHeaderView(/*frame: CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: 300)*/)
        tableHeaderView.nameLabel.text = user?.name
        tableHeaderView.screennameLabel.text = "@\((user?.screenName)!)"
        tableHeaderView.descriptionLabel.text = "\((user?.desc)!)"
        //tableHeaderView.createdDateLabel.text = "Joined on \((user?.createdAt)!)"
        tableHeaderView.followersCountLabel.text = "\((user?.followersCount)!)"
        tableHeaderView.followingCountLabel.text = "\((user?.followingCount)!)"
        tableHeaderView.likesCountLabel.text = "\((user?.favoritesCount)!)"
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
        self.origBannerImageHeightConstraintValue = tableHeaderView.bannerImageHeightConstraint.constant
        
        print ("CONSTRAINT = \(self.origBannerImageHeightConstraintValue)")
        self.tableView.tableHeaderView = tableHeaderView
        
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

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.shouldUpdateConstraints = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let headerView = self.tableView.tableHeaderView
        let size = headerView?.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        print ("HEADERHEIGHT = \(headerView?.frame.size.height)")
        print ("PROPOSED HEADERHEIGHT = \((size?.height)!)")
        
        if headerView?.frame.size.height != size?.height {
            headerView?.frame.size.height = (size?.height)!
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
        view.backgroundColor = .lightGray
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
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
        return cell
    }
    
    // MARK: - Scrollview
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!self.isMoreDataLoading) {
            let diff = scrollView.contentOffset.y - prevScrollOffset
            
            //print ("SCROLL OFSET Y = \(scrollView.contentOffset.y)")
            //print (self.navigationController?.navigationBar.frame.size.height)
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
            } else if self.shouldUpdateConstraints == true && scrollView.contentOffset.y < 0 && diff < 0 {//blur header image
                print("****** CHANGING CONSTRAINT BY = \(diff)")
                let headerView = self.tableView.tableHeaderView as! ProfileHeaderView
                headerView.bannerImageHeightConstraint.constant += abs(diff)
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                //self.view.layoutIfNeeded()
            }
        
        }
        prevScrollOffset = scrollView.contentOffset.y
    }

    func resetTableviewHeader () {
        print ("RESET Header height")
        let headerView = self.tableView.tableHeaderView as! ProfileHeaderView
        if headerView.bannerImageHeightConstraint.constant != self.origBannerImageHeightConstraintValue {
            headerView.bannerImageHeightConstraint.constant = self.origBannerImageHeightConstraintValue
            
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        resetTableviewHeader()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resetTableviewHeader()
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
