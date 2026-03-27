
import UIKit
import FirebaseFirestore
import FirebaseAuth

// Class fot the new jar view controller
class NewJarVC: UIViewController {
    
    @IBOutlet weak var newJatTF: UITextField!
    @IBOutlet weak var goalTF: UITextField!
    
    
    // Saves and closes the sheet
    @IBAction func saveJarBtn(_ sender: UIButton) {
        dismiss(animated: true)
        
        guard let jarName = newJatTF.text, !jarName.isEmpty,
            let goalAmount = goalTF.text, !goalAmount.isEmpty
        else { return }
        
            let db = Firestore.firestore()
            
            let data: [String: Any] = [
                "name": jarName,
                "balance": 0.00,
                "goal": Double(goalAmount) ?? 0.00,
                "date": Timestamp(date: Date())
            ]
        
        // Validates if the path exists and saves the new jar for the logged in user
        db.collection("users").document("\(Auth.auth().currentUser?.uid ?? "")").collection("jars").addDocument(data: data) { error in
            
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Jar \(jarName) created successfully")
            }
        }
        }
    
        
        override func viewDidLoad() {
            super.viewDidLoad()

    
    }
}
