import UIKit
import FirebaseAuth
import FirebaseFirestore

// Class for the profile view controller
class ProfileVC: UIViewController {
    
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!

    
    
    // Loads the profile labels and current dark mode state.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserName()
        loadUserEmail()
        darkMode.isOn = ThemeManager.shared.isDarkMode
    }

    // Fetches user's name
    // Reads the user's name from Firestore and updates the label.
    func loadUserName() {
        guard let userId = Auth.auth().currentUser?.uid else {
            lbName.text = "User not logged in!"
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                self?.lbName.text = "Welcome!"
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No user data found")
                self?.lbName.text = "User not logged in!"
                return
            }
            
            let name = data["name"] as? String ?? "User"
            
            DispatchQueue.main.async {
                self?.lbName.text = "\(name)"        }
        }
    }
    
    // Fetches user's email
    // Reads the current auth email and shows it on screen.
    func loadUserEmail() {
        lbEmail.text = Auth.auth().currentUser?.email ?? "User not logged in!"
    }
    

    @IBOutlet weak var darkMode: UISwitch!
    
    // Switch to turn on/off dark mode
    // Saves the dark mode change made by the user.
    @IBAction func darkModeChanged(_ sender: UISwitch) {
        ThemeManager.shared.setDarkMode(sender.isOn)
    }
    
    
    // Logs out and redirect to login screen
    // Signs the user out and navigates back to the login screen.
    @IBAction func signOutPress(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    
    // Opens the screen used for account and data management actions.
    @IBAction func openDataManagement(_ sender: UIButton) {
        performSegue(withIdentifier: "goToDataManagement", sender: self)
    }

    
    // Refreshes the labels and dark mode switch whenever the screen appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadUserName()
        loadUserEmail()
        darkMode.isOn = ThemeManager.shared.isDarkMode
    }
    
    
}
