import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    func signUp(
        name: String,
        lastName: String,
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let self, let user = result?.user else {
                completion(.failure(NSError(
                    domain: "AuthManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "User was not created."]
                )))
                return
            }

            let userData: [String: Any] = [
                "id": user.uid,
                "name": name,
                "lastName": lastName,
                "email": email
            ]

            self.db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(user.uid))
                }
            }
        }
    }

    func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(
                    domain: "AuthManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Login failed."]
                )))
                return
            }

            completion(.success(user.uid))
        }
    }

    func signOut() -> Result<Void, Error> {
        do {
            try auth.signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func getCurrentUserID() -> String? {
        auth.currentUser?.uid
    }
}
