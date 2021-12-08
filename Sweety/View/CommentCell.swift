//
//  CommentCell.swift
//  Sweety
//
//  Created by Burak İmdat on 21.11.2021.
//

import UIKit
import FirebaseAuth

class CommentCell: UITableViewCell {

    
    @IBOutlet weak var txtCommentUsername: UILabel!
    @IBOutlet weak var txtCommentDate: UILabel!
    @IBOutlet weak var txtComment: UILabel!
    @IBOutlet weak var imgCommentSettings: UIImageView!
    var delegate: CommentDelegate?
    var selectedComment: Comment!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setView(comment: Comment, delegate: CommentDelegate) {
        txtCommentUsername.text = comment.username
        txtComment.text = comment.commentText
        
        self.delegate = delegate
        self.selectedComment = comment
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm  dd.MM.YYYY"
        let commentDate = formatter.string(from: comment.commentDate)
        txtCommentDate.text = commentDate
        
        imgCommentSettings.isHidden = true
        
        if comment.userID == Auth.auth().currentUser?.uid {
            imgCommentSettings.isHidden = false
            imgCommentSettings.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(commentSettingsClicked))
            imgCommentSettings.addGestureRecognizer(tap)
        }
    }
    
    @objc func commentSettingsClicked() {
        delegate?.commentSettings(comment: selectedComment)
    }
}

protocol CommentDelegate {
    func commentSettings(comment: Comment)
}
