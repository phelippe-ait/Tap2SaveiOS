import FirebaseFirestore

// Function to create a new user
func createUser(with name: String, lastName: String, email: String) {
    let db = Firestore.firestore()
    
    let data: [String: Any] = [
        "name": name,
        "lastName": lastName,
        "email": email,
    ]
    
    // That's the firebase framework to create new entries
    db.collection("users").addDocument(data: data) { error in
        if let error = error {
            print("Error writing document: \(error)")
        } else {
            print("Test successful!")
        }
    }
}

