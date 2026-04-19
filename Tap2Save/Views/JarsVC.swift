import UIKit
import FirebaseAuth
import FirebaseFirestore

// Class for Jars View Controller
class JarsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var jarsTV: UITableView!
    
    var jars: [Jar] = []
    private let db = Firestore.firestore()
    
    // Connects the jars table view to this controller.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data source for Table view
        jarsTV.dataSource = self
        jarsTV.delegate = self
    }
    
    // Reloads jars each time the screen becomes visible.
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        
            loadJars()
        }
    
    // Load jars after changes
    // Refreshes the local jar list and redraws the table view.
    func loadJars() {
        fetchJars { [weak self] jars in
            self?.jars = jars
            DispatchQueue.main.async {
                self?.jarsTV.reloadData()
            }
        }
    }
    
    // Fetches jars from Firebase
    // Reads jar documents from Firestore and converts them into Jar models.
    func fetchJars(completion: @escaping ([Jar]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("jars")
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Error fetching jars: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let jars = snapshot?.documents.compactMap { doc -> Jar? in
                    let data = doc.data()
                    
                    let name = data["name"] as? String ?? ""
                    let balance = data["balance"] as? Double ?? 0.0
                    let goal = data["goal"] as? Double ?? 0.0
                    
                    return Jar(
                        id: doc.documentID,
                        name: name,
                        balance: balance,
                        goal: goal,
                        date: nil
                    )
                } ?? []
                
                completion(jars)
            }
    }
    
    // Returns how many jar rows should appear in the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jars.count
    }
    
    // Redirects to Jars details for the selected row
    // Builds the table view cell for a specific jar row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JarCell", for: indexPath) as! JarsDetailsTVCell
        
        let jar = jars[indexPath.row]
        cell.configure(with: jar)
        
        return cell
    }

    // Enables swipe-to-delete for jars in the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Shows a confirmation alert before deleting the selected jar.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let jar = jars[indexPath.row]
        let alert = UIAlertController(
            title: "Delete jar?",
            message: "This will remove \(jar.name) and all of its saved entries.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteJar(jar, at: indexPath)
        })

        present(alert, animated: true)
    }
    
    
    //
    // Sends the selected jar to the detail screen before the segue runs.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJarDetails",
           let destination = segue.destination as? JarDetailsVC,
        let indexPath = jarsTV.indexPathForSelectedRow {
            destination.selectedJar = jars[indexPath.row]
        }
    }

    // Deletes the jar document and all entryLog documents stored inside it.
    private func deleteJar(_ jar: Jar, at indexPath: IndexPath) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let jarRef = db.collection("users").document(userId).collection("jars").document(jar.id)

        jarRef.collection("entryLog").getDocuments { [weak self] snapshot, error in
            if let error = error {
                self?.showAlert(title: "Delete failed", message: error.localizedDescription)
                return
            }

            let batch = self?.db.batch()
            snapshot?.documents.forEach { document in
                batch?.deleteDocument(document.reference)
            }
            batch?.deleteDocument(jarRef)

            batch?.commit { error in
                if let error = error {
                    self?.showAlert(title: "Delete failed", message: error.localizedDescription)
                    return
                }

                self?.jars.remove(at: indexPath.row)
                self?.jarsTV.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

    // Shows a simple alert message when something goes wrong.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
