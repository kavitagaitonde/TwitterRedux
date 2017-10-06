//
//  HamburgerViewController.swift
//  TwitterRedux
//
//  Created by Kavita Gaitonde on 10/4/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentLeftMarginConstraint: NSLayoutConstraint!
    
    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            
            menuView.addSubview(menuViewController.view)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.contentLeftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    var originalLeftMargin: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.hamburgerViewController = self
        self.menuViewController = menuVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.logout()
    }

    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        switch sender.state {
        case UIGestureRecognizerState.began:
            originalLeftMargin = contentLeftMarginConstraint.constant
            //print ("BEGAN  translation.x -- \(translation.x)")
            //print ("BEGAN  originalleftmargin -- \(originalLeftMargin)")
            break
        case UIGestureRecognizerState.changed:
            contentLeftMarginConstraint.constant = originalLeftMargin + translation.x
//            print ("CHANGED  translation.x -- \(translation.x)")
//            print ("CHANGED  contentLeftMarginConstraint.constant -- \(contentLeftMarginConstraint.constant)")
            break
        case UIGestureRecognizerState.ended:
            UIView.animate(withDuration: 0.5, animations: {
                if velocity.x > 0 { //pan to right
                    self.contentLeftMarginConstraint.constant = self.view.frame.size.width - 50
//                    print ("ENDED to right translation.x -- \(translation.x)")
//                    print ("ENDED to right contentLeftMarginConstraint.constant -- \(self.contentLeftMarginConstraint.constant)")
                } else { //go back
                    self.contentLeftMarginConstraint.constant = 0
//                    print ("ENDED to left translation.x -- \(translation.x)")
//                    print ("ENDED to left contentLeftMarginConstraint.constant -- \(self.contentLeftMarginConstraint.constant)")

                }
            })
            break
        default: break
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "composeTweetSegue") {
            let composeController = segue.destination as! ComposeViewController
            composeController.composeMode = .tweet
            composeController.addTweet = { (tweet: Tweet) in
                /*self.tweets.insert(tweet, at: 0)
                self.tweetRecentId = self.tweets[0].id
                self.tableView.reloadData()*/
            }
        } /*else if(segue.identifier == "composeReplySegue") {
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
        }*/
        
    }

}
