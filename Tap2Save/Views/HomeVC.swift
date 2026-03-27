import UIKit
import FirebaseAuth
import FirebaseFirestore

// Class for Home screen View Controller
class HomeVC: UIViewController {
    
    @IBOutlet weak var welcomeUserLabel: UILabel!
    @IBOutlet weak var tapBtn: UIButton!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserName()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tapBtn.layer.cornerRadius = tapBtn.bounds.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTotalBalance()
    }
    
    // Refreshes the balance after adding new entries
    func refreshTotalBalance() {
        loadBalance { [weak self] total in
                    DispatchQueue.main.async {
                        self?.totalBalanceLabel.text = String(format: "$%.2f", total)
                    }
                }
    }

    // Fetches user's name to display at the top
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
    
    // Fetches the balance from Firebase
    func loadBalance(completion: @escaping (Double) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(0.0)
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).collection("jars").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching transactions: \(error.localizedDescription)")
                completion(0.0)
                return
            }
            
            let total = snapshot?.documents.reduce(0.0) { result, doc in
                let balance = doc.data()["balance"] as? Double ?? 0.0
                return result + balance
            } ?? 0.0
            
            completion(total)
        }
    }
    
    // Styles the button Tap to Save
    func styleTapBtb() {
        tapBtn.clipsToBounds = true
    }
    
}
