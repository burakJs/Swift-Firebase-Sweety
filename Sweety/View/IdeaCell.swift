//
//  IdeaCell.swift
//  Sweety
//
//  Created by Burak İmdat on 20.11.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CoreMedia

class IdeaCell: UITableViewCell {

    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtComment: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var txtLikeCount: UILabel!
    @IBOutlet weak var txtCommentCount: UILabel!
    @IBOutlet weak var imgIdeaSettings: UIImageView!
    
    var selectedIdea: Idea!
    var delegate: IdeaDelegate?
    let fireStore = Firestore.firestore()
    var likes: [Like] = [Like]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        imgLike.addGestureRecognizer(tap)
        imgLike.isUserInteractionEnabled = true
    }
    
    func getLikes() {
        
        let likeQuery = fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId).collection(LIKE_REF).whereField(USER_ID, isEqualTo: Auth.auth().currentUser?.uid ?? "")
        likeQuery.getDocuments { snap, error in
            self.likes = Like.getLikes(snapshot: snap)
            
            if self.likes.count > 0{
                self.imgLike.image = UIImage(named: "yildizRenkli")
            } else {
                self.imgLike.image = UIImage(named: "yildizTransparan")
            }
        }
    }
    
    @objc func likeTapped() {
        fireStore.runTransaction { transaction, err in
            let selectedIdeaSave: DocumentSnapshot
            do {
                try selectedIdeaSave = transaction.getDocument(self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId))
                
            } catch let err as NSError{
                debugPrint("Error in like:\(err.localizedDescription)")
                return nil
            }
            guard let oldLikeCount = (selectedIdeaSave.data()?[LIKE_COUNT] as? Int) else { return nil }
            let selectedIdeaRef = self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId)
            if self.likes.count > 0 {
               transaction.updateData([LIKE_COUNT: oldLikeCount - 1], forDocument: selectedIdeaRef)
               let oldLikeRef = self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId).collection(LIKE_REF).document(self.likes[0].documentID)
               transaction.deleteDocument(oldLikeRef)
            } else {
               transaction.updateData([LIKE_COUNT: oldLikeCount + 1], forDocument: selectedIdeaRef)
               let newLikeRef = self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId).collection(LIKE_REF).document()
               transaction.setData([USER_ID: Auth.auth().currentUser?.uid ?? ""], forDocument: newLikeRef)
            }
            return nil
        } completion: { object, err in
            if let err = err {
                debugPrint("Error : \(err.localizedDescription)")
            }
        }

//        fireStore.runTransaction ({ (transaction, errorPointer) in
//            let selectedIdeaSave: DocumentSnapshot
//            do {
//                try selectedIdeaSave = transaction.getDocument(self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId))
//            } catch let err as? NSError {
//                debugPrint("Error in like:\(err.localizedDescription)")
//                return nil
//            }
//            guard let oldLikeCount = (selectedIdeaSave.data()?[LIKE_COUNT] as? Int) else { return nil }
//            let selectedIdeaRef = self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId)
//            if self.likes.count > 0 {
//                transaction.updateData([LIKE_COUNT: oldLikeCount - 1], forDocument: selectedIdeaRef)
//                let oldLikeRef = self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId).collection(LIKE_REF).document(self.likes[0]).documentID
//                transaction.deleteDocument(oldLikeRef)
//            } else {
//                transaction.updateData([LIKE_COUNT: oldLikeCount - 1], forDocument: selectedIdeaRef)
//                let newLikeRef = self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId).collection(LIKE_REF).document()
//                transaction.setData([USER_ID: Auth.auth().currentUser?.uid ?? ""], forDocument: newLikeRef)
//            }
//
//            return nil
//        }) { object, error in
//            if let error  = error {
//                debugPrint("Error when is like :\(error.localizedDescription)")
//            }
//        }

    }
    
    func setView(idea: Idea, delegate: IdeaDelegate) {
        selectedIdea = idea
        self.delegate = delegate
        txtUsername.text = idea.username
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm  dd.MM.YYYY"
        let publishDate = dateFormatter.string(from: idea.publishDate)
        txtDate.text = publishDate
        
        txtComment.text = idea.ideaText
        txtLikeCount.text = String(describing: idea.likeCount!)
        txtCommentCount.text = String(describing: idea.commentCount!)
        
        imgIdeaSettings.isHidden = true
        
        if idea.userID == Auth.auth().currentUser?.uid {
            imgIdeaSettings.isHidden = false
            imgIdeaSettings.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(ideaSettingsClicked))
            
            imgIdeaSettings.addGestureRecognizer(tap)
        }
        getLikes()
    }
    
    @objc func ideaSettingsClicked() {
        delegate?.ideaSettingsClicked(idea: selectedIdea)
    }
}

protocol IdeaDelegate {
    func ideaSettingsClicked(idea: Idea)
     
}
