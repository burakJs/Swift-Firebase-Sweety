//
//  CreateAccountVC.swift
//  Sweety
//
//  Created by Burak İmdat on 21.11.2021.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateAccountVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var btnAlreadyHave: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        btnCreateAccount.layer.cornerRadius = 10
        btnAlreadyHave.layer.cornerRadius = 10
    }
    
    @IBAction func createAccountClicked(_ sender: UIButton) {
        guard let email = txtEmail.text,
              let password = txtPassword.text,
              let username = txtUsername.text
              else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (userInfo, error) in
            if let error = error {
                debugPrint("Error when is creating user : \(error.localizedDescription)")
            } else {
                let changeRequest = userInfo?.user.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    if let error = error {
                        debugPrint("Error when is updating user display name : \(error.localizedDescription)")
                    }
                }
                
                guard let userId = userInfo?.user.uid else { return }
                
                Firestore.firestore().collection(USERS_REF).document(userId).setData([
                    USERNAME: username,
                    CREATE_DATE: FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        debugPrint("Error when is adding user: \(error.localizedDescription)")
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func alreadyHaveClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
