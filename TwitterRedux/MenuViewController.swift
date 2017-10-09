//
//  MenuViewController.swift
//  TwitterRedux
//
//  Created by Kavita Gaitonde on 10/4/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var viewControllers: [UIViewController] = [UIViewController]()
    var menuOptions: [String] = ["Profile", "Timeline", "Mentions", "Accounts"]
    var hamburgerViewController: HamburgerViewController! 
    var rowHeight: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profileNC = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationViewController") as! UINavigationController
        let profileVC =  profileNC.viewControllers.first as! ProfileViewController
        profileVC.user = User.currentUser
        
        
        let timelineNC = storyboard.instantiateViewController(withIdentifier: "TimelineNavigationViewController") as! UINavigationController
        let timelineVC = timelineNC.viewControllers.first as! MainViewController
        timelineVC.timelineType = .home
        
        let mentionsNC = storyboard.instantiateViewController(withIdentifier: "TimelineNavigationViewController") as! UINavigationController
        let mentionsVC = mentionsNC.viewControllers.first as! MainViewController
        mentionsVC.timelineType = .mentions
        
        let accountsNC = storyboard.instantiateViewController(withIdentifier: "AccountsNavigationViewController") as! UINavigationController
        
        viewControllers.append(profileNC)
        viewControllers.append(timelineNC)
        viewControllers.append(mentionsNC)
        viewControllers.append(accountsNC)
        
        rowHeight = Int(self.tableView.frame.size.height) / menuOptions.count
        self.hamburgerViewController.contentViewController = timelineNC
        self.hamburgerViewController.navigationItem.title = menuOptions[1]        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.rowHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath)
        cell.textLabel?.text = menuOptions[indexPath.row]
        cell.textLabel?.textColor = .white
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.hamburgerViewController.contentViewController = viewControllers[indexPath.row]
        self.hamburgerViewController.navigationItem.title = menuOptions[indexPath.row]
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
