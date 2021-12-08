//
//  LoginVC.swift
//  Sweety
//
//  Created by Burak İmdat on 21.11.2021.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnLogin.layer.cornerRadius = 10
        btnCreateAccount.layer.cornerRadius = 10
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loading.hidesWhenStopped = true
        loading.stopAnimating()
    }
    @IBAction func loginClicked(_ sender: UIButton) {
        self.loading.startAnimating()
        guard let emailAddress = txtEmail.text, let password = txtPassword.text else { return }
        
        Auth.auth().signIn(withEmail: emailAddress, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error when is logging : \(error.localizedDescription)")
            } else {
                self.dismiss(animated: true) {
                    self.loading.stopAnimating()
                }
            }
        }
        
    }
    
}
