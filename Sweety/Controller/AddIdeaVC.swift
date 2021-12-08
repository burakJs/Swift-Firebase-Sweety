//
//  AddIdeaVC.swift
//  Sweety
//
//  Created by Burak İmdat on 20.11.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddIdeaVC: UIViewController {

    @IBOutlet weak var sgmCategories: UISegmentedControl!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPost: UITextView!
    @IBOutlet weak var btnShare: UIButton!
    
    let placeholderText = "Write your idea..."
    var selectedCategory = "Funny"
    override func viewDidLoad() {
        super.viewDidLoad()

        btnShare.layer.cornerRadius = 5
        txtPost.layer.cornerRadius = 7
        
        txtPost.text = placeholderText
        txtPost.textColor = .lightGray
        txtPost.delegate = self
    }

    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedCategory = Category.FUNNY.rawValue
        case 1:
            selectedCategory = Category.NEWS.rawValue
        case 2:
            selectedCategory = Category.ABSURD.rawValue
        default:
            select("HATA")
        }
    }
    
    @IBAction func shareClicked(_ sender: UIButton) {
        guard let user = Auth.auth().currentUser else { return }
        guard let username = user.displayName else { return }
        guard let post = txtPost.text, txtPost.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else { return }
        Firestore.firestore().collection(IDEA_REF).addDocument(data: [
            CATEGORY: selectedCategory,
            COMMENT_COUNT: 0,
            IDEA_TEXT: post,
            LIKE_COUNT: 0,
            USERNAME: username,
            PUBLISH_DATE: FieldValue.serverTimestamp(),
            USER_ID: user.uid
        ]) { err in
            if let err = err {
                print("ERROR: \(err.localizedDescription)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    

}

extension AddIdeaVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
}
