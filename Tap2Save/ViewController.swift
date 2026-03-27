//
//  ViewController.swift
//  Tap2Save
//
//  Created by Phelippe Duarte on 18/3/2026.
//

import UIKit
import FirebaseAuth

// Class for the login view controller
class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var newAccountBtn: UIButton!
    
    @IBAction func loginButtonPress(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        
        // Try to sign in validating Firebase data
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in guard self != nil else {return}
            
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            
            print("Successfully signed in!")
            self?.performSegue(withIdentifier: "toBarController", sender: nil)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }


}

