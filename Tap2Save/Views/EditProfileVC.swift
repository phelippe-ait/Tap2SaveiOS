import UIKit
import FirebaseAuth
import FirebaseFirestore

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var tfEditName: UITextField!
    @IBOutlet weak var tfEditEmail: UITextField!
    @IBOutlet weak var tfEditPassword: UITextField!

    private let db = Firestore.firestore()
    private var originalName = ""
    private var originalEmail = ""
    
    // Loads the current profile values into the edit form.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserProfile()
    }
    
    
    // Validates the form values and starts updating the profile.
    @IBAction func btnSaveEdit(_ sender: UIButton) {
        guard let user = Auth.auth().currentUser else {
            showAlert(title: "Not logged in", message: "Please log in again and try updating your profile.")
            return
        }

        let newName = tfEditName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newEmail = tfEditEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newPassword = tfEditPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !newName.isEmpty, !newEmail.isEmpty else {
            showAlert(title: "Missing information", message: "Name and email cannot be empty.")
            return
        }

        guard isValidEmail(newEmail) else {
            showAlert(title: "Invalid email", message: "Please enter a valid email address.")
            return
        }

        if !newPassword.isEmpty && newPassword.count < 6 {
            showAlert(title: "Weak password", message: "Password must be at least 6 characters long.")
            return
        }

        saveProfileChanges(for: user, name: newName, email: newEmail, password: newPassword)
    }
    
    
    // Updates only the fields that changed and reports the result to the user.
    private func saveProfileChanges(for user: FirebaseAuth.User, name: String, email: String, password: String) {
        let group = DispatchGroup()
        var errors: [String] = []
        var didUpdateAnything = false
        var didSendEmailVerification = false

        if needsNameUpdate(newName: name) {
            didUpdateAnything = true
            group.enter()
            updateUserName(userID: user.uid, newName: name) { result in
                if case .failure(let error) = result {
                    errors.append("Name: \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        if email != originalEmail {
            didUpdateAnything = true
            group.enter()
            updateEmail(user: user, newEmail: email) { [weak self] result in
                switch result {
                case .success:
                    didSendEmailVerification = true
                    group.leave()
                case .failure(let error):
                    errors.append("Email: \(error.localizedDescription)")
                    group.leave()
                }
            }
        }

        if !password.isEmpty {
            didUpdateAnything = true
            group.enter()
            updatePassword(user: user, newPassword: password) { result in
                if case .failure(let error) = result {
                    errors.append("Password: \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        guard didUpdateAnything else {
            showAlert(title: "No changes", message: "Update at least one field before saving.")
            return
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }

            if errors.isEmpty {
                self.originalName = name
                self.tfEditPassword.text = ""
                let successMessage = didSendEmailVerification
                    ? "Your profile was updated. Please check your new email inbox and verify the address to finish changing your email."
                    : "Your information was updated successfully."

                self.showAlert(title: "Profile updated", message: successMessage) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.showAlert(
                    title: "Update failed",
                    message: errors.joined(separator: "\n")
                )
            }
        }
    }
    
    
    // Updates the user's name inside their Firestore document.
    private func updateUserName(userID: String, newName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(userID).updateData(["name": newName]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Updates the user's email address in Firebase Auth.
    private func updateEmail(user: FirebaseAuth.User, newEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        user.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // Updates the user's password in Firebase Auth.
    private func updatePassword(user: FirebaseAuth.User, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Loads the saved profile data so the user can edit existing values.
    private func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            tfEditName.text = ""
            tfEditEmail.text = ""
            return
        }

        let currentEmail = Auth.auth().currentUser?.email ?? ""
        originalEmail = currentEmail
        tfEditEmail.text = currentEmail

        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.showAlert(title: "Load failed", message: error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else {
                self?.showAlert(title: "Profile not found", message: "Could not load your saved profile.")
                return
            }
            
            let name = data["name"] as? String ?? "User"
            
            DispatchQueue.main.async {
                self?.originalName = name
                self?.tfEditName.text = name
            }
        }
    }

    // Checks whether the edited name is different from the original one.
    private func needsNameUpdate(newName: String) -> Bool {
        originalName != newName
    }

    // Validates that the email text looks like a real email address.
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return predicate.evaluate(with: email)
    }

    // Shows an alert and optionally runs extra code when OK is tapped.
    private func showAlert(title: String, message: String, onOK: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            onOK?()
        })
        present(alert, animated: true)
    }
}
