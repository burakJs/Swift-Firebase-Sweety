//
//  CommentVC.swift
//  Sweety
//
//  Created by Burak İmdat on 21.11.2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CommentVC: UIViewController {

    var selectedIdea: Idea!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfComment: UITextField!
    
    var comments: [Comment] = [Comment]()
    
    var ideaRef: DocumentReference!
    let fireStore = Firestore.firestore()
    var username: String!
    var commentsListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        ideaRef = fireStore.collection(IDEA_REF).document(selectedIdea.documentId)
        
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        
        self.view.setKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        commentsListener = fireStore.collection(IDEA_REF).document(selectedIdea.documentId).collection(COMMENT_REF)
            .order(by: PUBLISH_DATE, descending: true)
            .addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                debugPrint("When is getting comments: \(error?.localizedDescription ?? "Undefined error")")
                return
            }
            self.comments.removeAll()
            self.comments = Comment.getComments(snapshot: snapshot)
            self.tableView.reloadData()
        }
    }
    @IBAction func commentAdd(_ sender: UIButton) {
        guard let commentText = tfComment.text, tfComment.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else { return }
        
        fireStore.runTransaction ({ transaction, errorPointer in
                
            let selectedIdeaSave: DocumentSnapshot
            
            do {
                try selectedIdeaSave = transaction.getDocument(self.ideaRef)
            }catch let error as NSError {
                debugPrint("Error : \(error.localizedDescription)")
                return nil
            }
           
            guard let oldCommentCount = (selectedIdeaSave.data()?[COMMENT_COUNT] as? Int) else { return nil }
            transaction.updateData([COMMENT_COUNT: oldCommentCount + 1], forDocument: self.ideaRef)
            
            let newCommentRef = self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId).collection(COMMENT_REF).document()
            transaction.setData([
                COMMENT_TEXT: commentText,
                PUBLISH_DATE: FieldValue.serverTimestamp(),
                USERNAME: self.username!,
                USER_ID: Auth.auth().currentUser?.uid ?? ""
            ], forDocument: newCommentRef)
            return nil
        }) { object, error in
            if let error = error {
                debugPrint("Error in transaction: \(error.localizedDescription)")
            }else {
                self.tfComment.text = ""
            }
        }

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditCommentSegue" {
            if let destVC = segue.destination as? EditCommentVC {
                if let commentData = sender as? (selectedComment: Comment, selectedIdea: Idea) {
                    destVC.selectedData = commentData
                }
            }
        }
    }
}

extension CommentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell{
            cell.setView(comment: comments[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
    
    
}

extension CommentVC: CommentDelegate {
    func commentSettings(comment: Comment) {
        let alert = UIAlertController(title: "Edit Comment", message: "You can edit and delete this comment", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Comment", style: .destructive) { action in
            self.deleteComment(comment: comment)
        }
        
        let editAction = UIAlertAction(title: "Edit Comment", style: .default) { action in
            self.performSegue(withIdentifier: "EditCommentSegue", sender: (comment, self.selectedIdea))
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteComment(comment: Comment){
//        self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId).collection(COMMENT_REF).document(comment.documentID).delete { error in
//            if let error = error {
//                debugPrint("When comment is deleting has error : \(error.localizedDescription)")
//            } else {
//                alert.dismiss(animated: true, completion: nil)
//            }
//        }
        
        self.fireStore.runTransaction { transaction, error in
            let saveSelectedIdea: DocumentSnapshot
            do {
                try saveSelectedIdea = transaction.getDocument(self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId))
            } catch let error as NSError {
                debugPrint("\(error.localizedDescription)")
                return nil
            }
            guard let oldCommentCount = (saveSelectedIdea.data()?[COMMENT_COUNT] as? Int) else { return nil }
            transaction.updateData([COMMENT_COUNT: oldCommentCount - 1], forDocument: self.ideaRef)
            let commentDelete = self.fireStore.collection(IDEA_REF).document(self.selectedIdea.documentId).collection(COMMENT_REF).document(comment.documentID)
            transaction.deleteDocument(commentDelete)
            return nil
        } completion: { object, error in
            if let error = error {
                debugPrint("Error when comment is deleting : \(error.localizedDescription)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }

    }
}
