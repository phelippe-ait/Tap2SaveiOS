

import UIKit
import FirebaseAuth
import FirebaseFirestore


class NewAccountVC: UIViewController {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBAction func createAccount(_ sender: UIButton) {
        
        guard let name = nameTF.text, !name.isEmpty,
              let lastName = lastNameTF.text, !lastName.isEmpty,
              let email = emailTF.text,  !email.isEmpty,
              let password = passwordTF.text, !password.isEmpty else {
            print("Please fill all fields")
            
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                    if let error = error {
                        // Todo: Handle the error)
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                        return
                    }
                    
                    // Todo show alert
                
            guard let authUser = authResult?.user else { self?.showAlert(title: "Error", message: "Something went wrong")
                return
            }
            
            let db = Firestore.firestore()
            
            let data: [String: Any] = [
                "uid": authUser.uid,
                "name": name,
                "lastName": lastName,
                "email": email
            ]
            
            
            db.collection("users").document(authUser.uid).setData(data) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    return
                }
                self?.performSegue(withIdentifier: "toBarController", sender: nil)
            }    
                }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
   
}
