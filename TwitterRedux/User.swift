//
//  User.swift
//  TwitterTwo
//
//  Created by Kavita Gaitonde on 9/25/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import Foundation

class User: NSObject {
    var id: Int
    var name: String?
    var screenName: String?
    var desc: String?
    var profileUrl: URL?
    var createdAt: String?
    var followersCount: Int?
    var followingCount: Int?
    var tweetsCount: Int?
    var favoritesCount: Int?
    var userDictionary: NSDictionary?
    static let formatter = DateFormatter()
    
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
            _currentUser = user
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.userDictionary!, options: [])
                UserDefaults.standard.set(data, forKey: "currentUserData")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUserData") 
            }
            UserDefaults.standard.synchronize()
        }
    }
    
}
