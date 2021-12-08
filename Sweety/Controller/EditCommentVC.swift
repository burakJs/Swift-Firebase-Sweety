//
//  EditCommentVC.swift
//  Sweety
//
//  Created by Burak İmdat on 29.11.2021.
//

import UIKit
import FirebaseFirestore

class EditCommentVC: UIViewController {

    @IBOutlet weak var txtComment: UITextView!
    @IBOutlet weak var btnUpdate: UIButton!
    
    var selectedData: (selectedComment: Comment, selectedIdea: Idea)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtComment.layer.cornerRadius = 10
        btnUpdate.layer.cornerRadius = 10
        txtComment.text = selectedData.selectedComment.commentText!
    }
    
    @IBAction func updateClicked(_ sender: UIButton) {
        guard let commentText = txtComment.text, txtComment.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else { return }
        Firestore.firestore().collection(IDEA_REF).document(selectedData.selectedIdea.documentId)
            .collection(COMMENT_REF).document(selectedData.selectedComment.documentID)
            .updateData([COMMENT_TEXT: commentText]) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            
        }
    }
    
}
