//
//  Status.swift
//  TwitterTwo
//
//  Created by Kavita Gaitonde on 9/28/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import Foundation

class Status: NSObject {
    
    var id: Int
    var text: String?
    var replyStatusId: Int
    
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as! Int
        text = dictionary["status"] as? String
        replyStatusId = (dictionary["replyStatusId"] as? Int) ?? 0
    }
    

}
