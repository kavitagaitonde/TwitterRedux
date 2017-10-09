//
//  User.swift
//  TwitterTwo
//
//  Created by Kavita Gaitonde on 9/25/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

class User: NSObject {
    var id: Int
    var name: String?
    var screenName: String?
    var desc: String?
    var profileUrl: URL?
    var bannerUrl: URL?
    var createdAt: String?
    var followersCount: Int?
    var followingCount: Int?
    var tweetsCount: Int?
    var favoritesCount: Int?
    var userDictionary: NSDictionary?
    static let formatter = DateFormatter()
    static var userAccounts: [String:User]?
    
    init(dictionary: NSDictionary) {
        userDictionary = dictionary
        
        id = dictionary["id"] as! Int
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        desc = dictionary["description"] as? String
        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        tweetsCount = dictionary["statuses_count"] as? Int
        favoritesCount = dictionary["favourites_count"] as? Int
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = URL(string: profileUrlString)
        } else {
            profileUrl = nil
        }
        let bannerUrlString = dictionary["profile_banner_url"] as? String
        if let bannerUrlString = bannerUrlString {
            bannerUrl = URL(string: bannerUrlString)
        } else {
            bannerUrl = nil
        }
        let timeString = dictionary["created_at"] as? String
        if let timeString = timeString {
            User.formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            let ts = User.formatter.date(from: timeString)
            User.formatter.dateFormat = "MMM d YYYY"
            createdAt = User.formatter.string(from: ts!)
        }
    }
    
    static var _currentUser: User?
    
    static var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? Data
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        
        set(user) {
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.userDictionary!, options: [])
                UserDefaults.standard.set(data, forKey: "currentUserData")
                self.addUserAccount(user)
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUserData")
                //self.removeUserAccount((_currentUser?.id)!)
            }
            _currentUser = user
            UserDefaults.standard.synchronize()
        }
    }
    
    static var accessToken: BDBOAuth1Credential? {
        get {
            if _currentUser != nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "userAccessTokens") as? Data
                if let userData = userData {
                    let dictionary = (NSKeyedUnarchiver.unarchiveObject(with: userData as Data) as? [String:BDBOAuth1Credential])!
                    return dictionary["\(_currentUser?.id)"]
                }
            }
            return nil
        }
        
        set(token) {
            if let token = token {
                let defaults = UserDefaults.standard
                let usersData = defaults.object(forKey: "userAccessTokens") as? Data
                var usersDictionary: [String:BDBOAuth1Credential] = [String:BDBOAuth1Credential]()
                if let usersData = usersData {//update
                    usersDictionary = (NSKeyedUnarchiver.unarchiveObject(with: usersData as Data) as? [String:BDBOAuth1Credential])!
                } else {//create
                }
                usersDictionary["\(_currentUser?.id)"] = token
                let data = NSKeyedArchiver.archivedData(withRootObject: usersDictionary)
                UserDefaults.standard.set(data, forKey: "userAccessTokens")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    static func removeAccessToken(_ forUser: User) {
        let defaults = UserDefaults.standard
        let usersData = defaults.object(forKey: "userAccessTokens") as? Data
        var usersDictionary: [String:BDBOAuth1Credential] = [String:BDBOAuth1Credential]()
        if let usersData = usersData {//update
            usersDictionary = (NSKeyedUnarchiver.unarchiveObject(with: usersData as Data) as? [String:BDBOAuth1Credential])!
            usersDictionary["\(forUser.id)"] = nil
            let data = NSKeyedArchiver.archivedData(withRootObject: usersDictionary)
            UserDefaults.standard.set(data, forKey: "userAccessTokens")
            UserDefaults.standard.synchronize()
        }
    }
    
    static func getUserAccounts () -> [User]? {
        let defaults = UserDefaults.standard
        let usersData = defaults.object(forKey: "userAccounts") as? Data
        let usersDictionary: [String:Any]?
        if let usersData = usersData {
            usersDictionary = try! JSONSerialization.jsonObject(with: usersData, options: []) as! [String:Any]
            if usersDictionary != nil {
                var users: [User] = []
                for user in (usersDictionary?.values)! {
                    users.append(User(dictionary: user as! NSDictionary))
                }
                return users
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    static func getUserAccount (_ id:Int) -> User? {
        let defaults = UserDefaults.standard
        let usersData = defaults.object(forKey: "userAccounts") as? Data
        let usersDictionary: [String:Any]?
        if let usersData = usersData {
            usersDictionary = try! JSONSerialization.jsonObject(with: usersData, options: []) as! [String:Any]
            guard let user = usersDictionary else {
                return nil
            }
            return User(dictionary: user as NSDictionary)
        } else {//create
            return nil
        }
    }
        
    static func addUserAccount (_ user:User?) {

        if let user = user {
            let defaults = UserDefaults.standard
            let usersData = defaults.object(forKey: "userAccounts") as? Data
            var usersDictionary: /*[Any] = [Any]() */ [String:Any] = [String:Any]()
            if let usersData = usersData {//update
                usersDictionary = try! JSONSerialization.jsonObject(with: usersData, options: []) as! [String:Any]
            } else {//create
                //usersDictionary = ["\(user.id)":user.name]
                //usersDictionary = [user.userDictionary!]
            }
            usersDictionary["\(user.id)"] = user.userDictionary!
            //usersDictionary.append(user.userDictionary!)
            let data = try! JSONSerialization.data(withJSONObject: usersDictionary, options: [])
            UserDefaults.standard.set(data, forKey: "userAccounts")
            UserDefaults.standard.synchronize()
        }
    
    }

    static func removeUserAccount (_ id:Int) {
        let defaults = UserDefaults.standard
        let usersData = defaults.object(forKey: "userAccounts") as? Data
        let usersDictionary: [String:Any]?
        if let usersData = usersData {
            usersDictionary = try! JSONSerialization.jsonObject(with: usersData, options: []) as! [String:Any]
            if usersDictionary?["\(id)"] != nil {
                usersDictionary?["\(id)"] = nil
                if usersDictionary?.values.count == 0 {
                    UserDefaults.standard.removeObject(forKey: "userAccounts")
                } else {
                    let data = try! JSONSerialization.data(withJSONObject: usersDictionary, options: [])
                    UserDefaults.standard.set(data, forKey: "userAccounts")
                }
                UserDefaults.standard.synchronize()
            }
        }
    }

}
