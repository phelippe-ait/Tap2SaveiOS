import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    
    
    @IBAction func signOutPress(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            self.performSegue(withIdentifier: "toLogin", sender: nil)
            
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
}
