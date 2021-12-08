//
//  Comment.swift
//  Sweety
//
//  Created by Burak İmdat on 21.11.2021.
//

import Foundation
import Firebase

class Comment {
    private(set) var username: String!
    private(set) var commentDate: Date!
    private(set) var commentText: String!
    private(set) var userID: String!
    private(set) var documentID: String!
    
    init(username: String, commentDate: Date, commentText: String, userID: String, documentID: String) {
        self.username = username
        self.commentDate = commentDate
        self.commentText = commentText
        self.userID = userID
        self.documentID = documentID
    }
    
    class func getComments(snapshot: QuerySnapshot?) -> [Comment] {
        var comments: [Comment] = [Comment]()
        guard let snap = snapshot else { return comments }
        
        for save in snap.documents {
            let data = save.data()
            let username = data[USERNAME] as? String ?? "Guest"
            let ts = data[PUBLISH_DATE] as? Timestamp ?? Timestamp()
            let publishedDate = ts.dateValue()
            let commentText = data[COMMENT_TEXT] as? String ?? "No Comment"
            let userID = data[USER_ID] as? String ?? ""
            let documentID = save.documentID
            let newComment = Comment(username: username, commentDate: publishedDate, commentText: commentText, userID: userID, documentID: documentID)
            comments.append(newComment)
        }
        return comments
    }
}
