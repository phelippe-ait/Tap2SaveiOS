import UIKit
import FirebaseAuth
import FirebaseFirestore

// Class for Home screen View Controller
class HomeVC: UIViewController {
    
    @IBOutlet weak var welcomeUserLabel: UILabel!
    @IBOutlet weak var tapBtn: UIButton!
    @IBOutlet weak var totalBalanceLabel: UILabel!

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    // Loads the home screen and fetches the user's name.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserName()
    }
    
    // Makes the tap button round after the layout size is known.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tapBtn.layer.cornerRadius = tapBtn.bounds.width / 2
    }
    
    // Refreshes balance and profile data whenever the screen appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTotalBalance()
        loadUserName()
    }
    
    // Refreshes the balance after adding new entries
    // Recalculates the total balance and updates the label on screen.
    func refreshTotalBalance() {
        loadBalance { [weak self] total in
                    DispatchQueue.main.async {
                        self?.totalBalanceLabel.text = self?.formatCurrency(total)
                    }
                }
    }

    // Fetches user's name to display at the top
    // Reads the user's name from Firestore and shows it in the welcome message.
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
    // Sums all jar balances in Firestore and returns the total amount.
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
    // Ensures the tap button clips to its rounded shape.
    func styleTapBtb() {
        tapBtn.clipsToBounds = true
    }
    
    // Formats a number as currency with separators, like $2,000.00.
    private func formatCurrency(_ amount: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: amount)) ?? String(format: "$%.2f", amount)
    }
    
}
