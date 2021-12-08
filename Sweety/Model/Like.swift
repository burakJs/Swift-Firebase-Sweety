//
//  Like.swift
//  Sweety
//
//  Created by Burak İmdat on 30.11.2021.
//

import Foundation
import Firebase
class Like {
    private(set) var userID: String
    private(set) var documentID: String
    
    init(userID: String, documentID: String) {
        self.userID = userID
        self.documentID = documentID
    }
    class func getLikes(snapshot: QuerySnapshot?) -> [Like] {
        var likes: [Like] = [Like]()
        guard let snap = snapshot else { return likes }
        
        for save in snap.documents {
            let data = save.data()
            let userID = data[USER_ID] as? String ?? ""
            let documentID = save.documentID
            let newLike = Like(userID: userID, documentID: documentID)
            
            likes.append(newLike)
        }
        return likes
    }
}
    
 
