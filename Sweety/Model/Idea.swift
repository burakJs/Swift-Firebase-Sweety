//
//  Idea.swift
//  Sweety
//
//  Created by Burak İmdat on 20.11.2021.
//

import Foundation
import Firebase

class Idea {
    private(set) var username: String!
    private(set) var publishDate: Date!
    private(set) var ideaText: String!
    private(set) var commentCount: Int!
    private(set) var likeCount: Int!
    private(set) var documentId: String!
    private(set) var userID: String!
    
    init(username: String, publishDate: Date, ideaText: String, commentCount: Int, likeCount: Int, documentId: String, userID: String) {
        
        self.username = username
        self.publishDate = publishDate
        self.ideaText = ideaText
        self.commentCount = commentCount
        self.likeCount = likeCount
        self.documentId = documentId
        self.userID = userID
    }
    
    class func getIdeas(snapshot: QuerySnapshot?, byLikeCount: Bool = false, byCommentCount: Bool = false) -> [Idea] {
        var ideas: [Idea] = [Idea]()
        guard let snap = snapshot else { return ideas}
        for document in snap.documents {
            let data = document.data()
            
            let username = data[USERNAME] as? String ?? "Guest"
            let ts = data[PUBLISH_DATE] as? Timestamp ?? Timestamp()
            let publishDate = ts.dateValue()
            
            let ideaText = data[IDEA_TEXT] as? String ?? ""
            let commentCount = data[COMMENT_COUNT] as? Int ?? 0
            let likeCount = data[LIKE_COUNT] as? Int ?? 0
            let documentId = document.documentID
            let userID = data[USER_ID] as? String ?? ""
            
            let newIdea = Idea(username: username, publishDate: publishDate, ideaText: ideaText, commentCount: commentCount, likeCount: likeCount, documentId: documentId, userID: userID)
            ideas.append(newIdea)
        }
        if byLikeCount {
            ideas.sorted { $0.likeCount > $1.likeCount }
        }
        if byCommentCount {
            ideas.sorted { $0.commentCount > $1.commentCount }
        }
        return ideas
    }
}
