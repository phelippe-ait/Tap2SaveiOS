import UIKit
import FirebaseAuth
import FirebaseFirestore

// Class for the profile view controller
class DataManagementVC: UIViewController {
    
    // Deletes user Jars and entries
    // Asks for confirmation before deleting all saved jar data.
    @IBAction func deleteUserData(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete all data?",
            message: "This will remove all jars and savings permanently.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteAllUserData { success in
                DispatchQueue.main.async {
                    if success {
                        print("All Firestore data deleted")
                    } else {
                        print("Failed to delete all Firestore data")
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    // Deletes user account and data from Firebase
    // Asks for confirmation before deleting the account and all related data.
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete your account and all data?",
            message: "This will remove your data and ability to log in permanently.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteAccount()
        })
        
        present(alert, animated: true)
    }
    
    
    
    
    // Deletes user data from Firebase
    // Removes every jar, entry log, and the user's Firestore profile document.
    func deleteAllUserData(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        let jarsRef = userRef.collection("jars")
        
        jarsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching jars: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let jars = snapshot?.documents else {
                completion(false)
                return
            }
            
            // If there are no jars, just delete the user document
            if jars.isEmpty {
                userRef.delete { error in
                    if let error = error {
                        print("Error deleting user document: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
                return
            }
            
            let group = DispatchGroup()
            var hasError = false
            
            for jar in jars {
                group.enter()
                
                let entryLogRef = jar.reference.collection("entryLog")
                
                entryLogRef.getDocuments { savingsSnapshot, error in
                    if let error = error {
                        print("Error fetching entryLog: \(error.localizedDescription)")
                        hasError = true
                        group.leave()
                        return
                    }
                    
                    let batch = db.batch()
                    
                    savingsSnapshot?.documents.forEach { saving in
                        batch.deleteDocument(saving.reference)
                    }
                    
                    batch.deleteDocument(jar.reference)
                    
                    batch.commit { error in
                        if let error = error {
                            print("Error deleting jar data: \(error.localizedDescription)")
                            hasError = true
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                if hasError {
                    completion(false)
                    return
                }
                
                // delete users document after all jars are gone
                userRef.delete { error in
                    if let error = error {
                        print("Error deleting user document: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }
    
    // Deletes user account and data from Firebase
    // Deletes the Firestore data first, then removes the Firebase Auth account.
    func deleteAccount() {
        deleteAllUserData { success in
            guard success else {
                print("Could not delete Firestore data")
                return
            }
            
            Auth.auth().currentUser?.delete { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error deleting auth user: \(error.localizedDescription)")
                    } else {
                        print("User deleted")
                        self.performSegue(withIdentifier: "toLogin", sender: nil)
                    }
                }
            }
        }
    }
    
    
}
