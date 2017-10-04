//
//  MeViewController.swift
//  TwitterTwo
//
//  Created by Kavita Gaitonde on 9/30/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = User.currentUser
        self.nameLabel.text = user?.name
        self.screenLabel.text = "@\((user?.screenName)!)"
        self.descLabel.text = "\((user?.desc)!)"
        self.createdDateLabel.text = "Joined on \((user?.createdAt)!)"
        self.followersCountLabel.text = "\((user?.followersCount)!)"
        self.followingCountLabel.text = "\((user?.followingCount)!)"
        self.favoritesCountLabel.text = "\((user?.favoritesCount)!)"
        self.tweetCountLabel.text = "\((user?.tweetsCount)!)"
        self.profileImageView.layer.cornerRadius = 5.0
        self.profileImageView.clipsToBounds = true
        if (user?.profileUrl != nil) {
            self.profileImageView.setImageWith((user?.profileUrl!)!)
        } else {
            self.profileImageView.image = nil
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
