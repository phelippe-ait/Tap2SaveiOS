
import UIKit
import FirebaseFirestore
import FirebaseAuth


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
