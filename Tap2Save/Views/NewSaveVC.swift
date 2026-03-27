import UIKit
import Firebase
import FirebaseAuth

class NewSaveVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
        
    @IBOutlet weak var newSaveTF: UITextField!
    @IBOutlet weak var tableViewJars: UITableView!
    
    var jars: [Jar] = []
    var selectedJarId: String?
    
    @IBAction func saveNewEntry(_ sender: UIButton) {
        
        guard let text = newSaveTF.text, !text.isEmpty,
              let amount = Double(text), amount > 0 else {
            showAlert(title: "Invalid amount", message: "Please enter a valid amount")
            return
        }
        
        guard let jarId = selectedJarId else {
            showAlert(title: "No jar selected", message: "Select a jar first")
            return
        }
        
        addValueToJar(jarId: jarId, amount: amount)
        
        dismiss(animated: true)
    }
    
    func fetchJars() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let db = Firestore.firestore()
            
            db.collection("users")
                .document(uid)
                .collection("jars")
                .getDocuments { [weak self] snapshot, error in
                    if let error = error {
                        print("Error fetching jars: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    self?.jars = documents.compactMap { document in
                        let data = document.data()
                        let name = data["name"] as? String ?? "Unnamed Jar"
                        let balance = data["balance"] as? Double ?? 0.0
                        let goal = data["goal"] as? Double ?? 0.0
                        let date = data["date"] as? Date ?? Date()
                        
                        return Jar(
                            id: document.documentID,
                            name: name,
                            balance: balance,
                            goal: goal,
                            date: date
                        )
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableViewJars.reloadData()
                    }
                }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return jars.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JarCell", for: indexPath)
            
            let jar = jars[indexPath.row]
            cell.textLabel?.text = jar.name
            cell.detailTextLabel?.text = String(format: "$%.2f", jar.balance)
            
            // selection checkmark
            cell.accessoryType = (jar.id == selectedJarId) ? .checkmark : .none
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedJarId = jars[indexPath.row].id
            tableView.reloadData()
        }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableViewJars.dataSource = self
        tableViewJars.delegate = self
        
        newSaveTF.delegate = self
        newSaveTF.keyboardType = .decimalPad
        
        fetchJars()
    }
    
    // Logic to add amount to total balance
    func addValueToJar(jarId: String, amount: Double) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let db = Firestore.firestore()
            let jarRef = db.collection("users").document(uid).collection("jars").document(jarId)
            
            let entryData: [String: Any] = [
                "amount": amount,
                "date": Timestamp(date: Date())
            ]
            
            // First save the entry in entryLog
            jarRef.collection("entryLog").addDocument(data: entryData) { [weak self] error in
                if let error = error {
                    print("Error adding entry log: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: "Could not save entry.")
                    return
                }
                
                // Then update balance
                jarRef.getDocument { snapshot, error in
                    if let error = error {
                        print("Error fetching jar: \(error.localizedDescription)")
                        self?.showAlert(title: "Error", message: "Could not update jar balance.")
                        return
                    }
                    
                    let currentBalance = snapshot?.data()?["balance"] as? Double ?? 0.0
                    let newBalance = currentBalance + amount
                    
                    jarRef.updateData(["balance": newBalance]) { error in
                        if let error = error {
                            print("Error updating balance: \(error.localizedDescription)")
                            self?.showAlert(title: "Error", message: "Could not update balance.")
                        } else {
                            print("Amount $\(amount) added successfully")
                            self?.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    
    func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    
}
