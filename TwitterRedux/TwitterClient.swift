//
//  TwitterClient.swift
//  TwitterTwo
//
//  Created by Kavita Gaitonde on 9/25/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

let twitterBaseUrl = "https://api.twitter.com"
let twitterConsumerKey = "SjiFlt58uAyjrXU8RGeRc6sK3"
let twitterConsumerSecret = "H6jiqvTrW1pKT59SaggiFNLYwe6KxgeRTJdH3r2KFRM9asbKiD"

enum TimelineType: Int {
    case home = 0, user, mentions
}

class TwitterClient: BDBOAuth1SessionManager {
    
    
    static let sharedInstance = TwitterClient (baseURL: URL(string: twitterBaseUrl)!, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?

    func login (success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()

        
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterredux://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in
                let token = (requestToken?.token)!
                print("Got Oauth token =\(token)")
                let url = URL(string: "\(twitterBaseUrl)/oauth/authorize?oauth_token=\(token)")
            UIApplication.shared.open(url!, options: [:], completionHandler: {(result: Bool) in
            })
            }, failure: { (error: Error?) in
                print("Error fetching Oauth token =\((error?.localizedDescription)!)")
                self.loginFailure?(error!)
        })
    }
    
    func logout() {
        deauthorize()
        User.currentUser = nil
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserLoggedOut"), object: nil)
    }
    
    func switchAccount(_ toUser: User) {
        deauthorize()
        User.currentUser = toUser
        self.requestSerializer.saveAccessToken(User.accessToken)
        print("**** Switched user to = \(User.currentUser?.name)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadView"), object: nil)
    }
    
    func removeAccount(_ forUser: User) {
        User.removeUserAccount(forUser.id)
        User.removeAccessToken(forUser)
        print("**** Removed user  = \(forUser.name)")
        if forUser.id == User.currentUser?.id {
            deauthorize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadView"), object: nil)
        }
        
    }
    
    func handleOpenUrl(url: URL) {
        print(url.description)
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            print("Success fetching access token = \((accessToken?.token)!)")
            
            self.userCredentials(success: {(user: User) in
                User.currentUser = user
                User.accessToken = accessToken
                self.loginSuccess?()
            }, failure: {(error: Error?) in
                 self.loginFailure?(error!)   
            })
        }) { (error: Error?) in
                print("Error fetching access token = \((error?.localizedDescription)!)")
        }
    }
    
    func userCredentials (success: @escaping (User) -> (),  failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                let userDict = response as! NSDictionary
                print("Account info - \(userDict)")
                //create and save user
                let user = User(dictionary: userDict)
                success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error fetching user account - \(error.localizedDescription)")
            failure(error)
        })
    }

    func getTimeLine (forUser: User, forType: TimelineType, afterId: Int, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        getTimeLine(forUser: forUser, forType: forType, parameters: ["since_id": afterId], success: success, failure: failure)
    }
    
    func getTimeLine (forUser: User?, forType: TimelineType, beforeId: Int, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        getTimeLine(forUser: forUser, forType: forType, parameters: ["max_id": beforeId+1], success: success, failure: failure)
    }
    
    func getTimeLine (forUser: User?, forType: TimelineType, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        getTimeLine(forUser: forUser, forType: forType, parameters: nil, success: success, failure: failure)
    }
    
    func getTimeLine (forUser: User?, forType: TimelineType,  parameters: [String: Any]?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        var url : String?
        var params : [String: Any] = [:]
        
        if parameters != nil {
            params = parameters!
        }
        switch forType {
        case .home:
            url = "1.1/statuses/home_timeline.json"
            break
        case .user:
            url = "1.1/statuses/user_timeline.json"
            if let user = forUser {
                params["user_id"] = user.id
            }
            break
        case .mentions:
            url = "1.1/statuses/mentions_timeline.json"
            break
        }
        get(url!, parameters: params, progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                print("Success fetching \(self.getTimelineType(forType)) timeline - ")
                let dictionaries = response as! [NSDictionary]
                success(Tweet.tweetsArray(dictionaries: dictionaries))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error fetching \(self.getTimelineType(forType)) timeline - \(error.localizedDescription)")
            failure(error)
        })
    }

    func getTimelineType (_ from: TimelineType) -> String {
        switch from {
        case .home:
            return "home"
        case .user:
            return "user"
        case .mentions:
            return "mentions"
        }
    }
    
    func favorite (tweetId: Int, success: @escaping (Tweet) -> (),  failure: @escaping (Error) -> ()) {
        post("1.1/favorites/create.json", parameters: ["id": tweetId], progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                print("Success favoriting tweet - \(tweet)")
                success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error favoriting tweet - \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func unFavorite (tweetId: Int, success: @escaping (Tweet) -> (),  failure: @escaping (Error) -> ()) {
        post("1.1/favorites/destroy.json", parameters: ["id": tweetId], progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                print("Success unfavoriting tweet - \(tweet)")
                success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error unfavoriting tweet - \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func getTweet (tweetId: Int, success: @escaping (Tweet) -> (),  failure: @escaping (Error) -> ()) {
        get("1.1/statuses/show.json", parameters: ["id": tweetId], progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                print("Success getting tweet - \(tweet)")
                success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error getting tweet - \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func tweet (text: String, success: @escaping (Tweet) -> (),  failure: @escaping (Error) -> ()) {
        post("1.1/statuses/update.json", parameters: ["status": text], progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                print("Success sending tweet - \(tweet)")
                success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error sending tweet - \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func untweet (tweetId: Int, success: @escaping (Tweet) -> (),  failure: @escaping (Error) -> ()) {
        post("1.1/statuses/destroy/\(tweetId).json", parameters: nil, progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                print("Success sending untweet - \(tweet)")
                success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error sending untweet - \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func retweet (tweetId: Int, success: @escaping (Tweet) -> (),  failure: @escaping (Error) -> ()) {
        post("1.1/statuses/retweet/\(tweetId).json", parameters: nil, progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                print("Success sending retweet - \(tweet)")
                success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error sending retweet - \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func unretweet (tweetId: Int, success: @escaping (Tweet) -> (),  failure: @escaping (Error) -> ()) {
        post("1.1/statuses/unretweet/\(tweetId).json", parameters: nil, progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                //BUGBUG: Bug in Twitter its not redcing the retweet count, and setting retweeted to false upon unretweeting
                if tweet.retweeted {
                    self.getTweet(tweetId: tweet.id, success: { (tweet: Tweet) in
                        success(tweet)
                    }, failure: { (error: Error) in
                        //last resort
                        tweet.retweeted = false
                        tweet.retweetCount = tweet.retweetCount - 1
                        success(tweet)
                    })
                } else {
                    print("Success sending unretweet - \(tweet)")
                    success(tweet)
                }
         }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error sending unretweet - \(error.localizedDescription)")
            failure(error)
        })
    }

    func reply (text: String, toTweetId: Int, success: @escaping (Tweet) -> (),  failure: @escaping (Error) -> ()) {
        post("1.1/statuses/update.json", parameters: ["status": text, "in_reply_to_status_id": toTweetId], progress: nil
            , success: { (task: URLSessionDataTask?, response: Any?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                print("Success sending reply - \(tweet)")
                success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error sending reply - \(error.localizedDescription)")
            failure(error)
        })
    }

}
