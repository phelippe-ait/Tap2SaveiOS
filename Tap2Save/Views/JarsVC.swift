import UIKit
import FirebaseAuth
import FirebaseFirestore

class JarsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var jarsTV: UITableView!
    
    var jars: [Jar] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jarsTV.dataSource = self
        jarsTV.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            loadJars()
        }
    
    func loadJars() {
        fetchJars { [weak self] jars in
            self?.jars = jars
            DispatchQueue.main.async {
                self?.jarsTV.reloadData()
            }
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JarCell", for: indexPath) as! JarsDetailsTVCell
        
        let jar = jars[indexPath.row]
        cell.configure(with: jar)
        
        return cell
    }
    
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJarDetails",
           let destination = segue.destination as? JarDetailsVC,
        let indexPath = jarsTV.indexPathForSelectedRow {
            destination.selectedJar = jars[indexPath.row]
           }
        }
    }

