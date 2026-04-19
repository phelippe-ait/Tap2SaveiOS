import UIKit
import Firebase
import FirebaseAuth

// Class for the New entry view controller
class NewSaveVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
        
    @IBOutlet weak var newSaveTF: UITextField!
    @IBOutlet weak var tableViewJars: UITableView!
    
    var jars: [Jar] = []
    var selectedJarId: String?
    
    // Checks the new amount and selected jar before saving an entry.
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
    }
    
    // Fetches jars from Firebase
    // Loads all jars for the logged-in user so one can be selected.
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
    
    
    // Returns the number of jar rows to show in the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return jars.count
        }
        
        // Configures each table row with jar information and selection state.
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JarCell", for: indexPath)
            
            let jar = jars[indexPath.row]
            cell.textLabel?.text = jar.name
            cell.detailTextLabel?.text = String(format: "$%.2f", jar.balance)
            
            // selection checkmark
            cell.accessoryType = (jar.id == selectedJarId) ? .checkmark : .none
            
            return cell
        }
        
        // Saves which jar the user tapped in the table.
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedJarId = jars[indexPath.row].id
            tableView.reloadData()
        }
    
    
    
    // Sets up the table view, keyboard type, and first jar fetch.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableViewJars.dataSource = self
        tableViewJars.delegate = self
        
        newSaveTF.delegate = self
        newSaveTF.keyboardType = .decimalPad
        
        fetchJars()
    }
    
    // Refreshes the list of jars whenever this screen appears again.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableViewJars.dataSource = self
        tableViewJars.delegate = self
        
        newSaveTF.delegate = self
        newSaveTF.keyboardType = .decimalPad
        
        fetchJars()
    }
    
    // Logic to add amount to total balance
    // Saves the entry in Firestore and increases the selected jar balance.
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
                            if let selectedJar = self?.jars.first(where: { $0.id == jarId }) {
                                if newBalance >= selectedJar.goal {
                                    self?.showAlert(
                                        title: "🎉 Goal reached!",
                                        message: "You reached your goal for \(selectedJar.name)!"
                                    ) {
                                        self?.goToJarsScreen()
                                    }
                                    return
                                }
                            }

                            self?.showAlert(
                                title: "Saved",
                                message: "Your saving amount was added successfully."
                            ) {
                                self?.goToJarsScreen()
                            }
                        }
                    }
                }
                
                
            }
        }
    
    // Shows an alert and optionally runs extra code after OK is pressed.
    func showAlert(title: String, message: String, onOk: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            onOk?()
        })
        
        present(alert, animated: true)
    }

    // Closes this screen and switches the user to the jars tab.
    private func goToJarsScreen() {
        dismiss(animated: true) { [weak self] in
            self?.tabBarController?.selectedIndex = 1
            self?.presentingViewController?.tabBarController?.selectedIndex = 1
        }
    }
}
