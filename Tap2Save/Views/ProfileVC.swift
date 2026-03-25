import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    @IBOutlet weak var signOutBtn: UIButton!
    
    
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
