//
//  AccountsViewController.swift
//  TwitterRedux
//
//  Created by Kavita Gaitonde on 10/8/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func handlePan(_ sender: AnyObject) {
    }
    var totalAccounts : [User] = []
    var rowHeight: Int = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()

        totalAccounts.append(User.currentUser!)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        self.tableView.tableFooterView = UIView()
        //rowHeight = Int(self.tableView.frame.size.height) / totalAccounts.count
        
        totalAccounts = User.getUserAccounts()!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalAccounts.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.rowHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountsTableViewCell", for: indexPath)
        if indexPath.row == totalAccounts.count {
            cell.textLabel?.text = "Add account"
        } else {
            let user = totalAccounts[indexPath.row]
            cell.textLabel?.text = user.name
        }
        cell.textLabel?.textColor = .white
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == totalAccounts.count {
            TwitterClient.sharedInstance?.logout()
            TwitterClient.sharedInstance?.login(success: {
                print ("Login successful")
                //self.performSegue(withIdentifier: "loginSegue", sender: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "HamburgerViewController")
                UIApplication.shared.delegate?.window??.rootViewController = vc
                }, failure: { (error: Error?) in
                    print("Error in login")
            })

        } else {
            //switch user
            let user = totalAccounts[indexPath.row]
            if user.id == User.currentUser?.id {
                //do nothing
                print("Already logged in.....\(user.name)")
            } else {
                TwitterClient.sharedInstance?.switchAccount(user)
            }
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = totalAccounts[indexPath.row]
            if user.id == User.currentUser?.id {
                
            } else {
                TwitterClient.sharedInstance?.removeAccount(user)
            }
        }
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
