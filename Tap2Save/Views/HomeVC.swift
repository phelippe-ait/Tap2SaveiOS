import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeVC: UIViewController {
    
    @IBOutlet weak var welcomeUserLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserName()
    }
    
    func loadUserName() {
        guard let userId = Auth.auth().currentUser?.uid else {
            welcomeUserLabel.text = "Welcome!"
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                self?.welcomeUserLabel.text = "Welcome!"
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No user data found")
                self?.welcomeUserLabel.text = "Welcome!"
                return
            }
            
            let name = data["name"] as? String ?? "User"
            
            DispatchQueue.main.async {
                self?.welcomeUserLabel.text = "Welcome, \(name)!"        }
        }
    }
}
