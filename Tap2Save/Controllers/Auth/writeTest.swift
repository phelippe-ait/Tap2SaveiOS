import FirebaseFirestore

func createUser(with name: String, lastName: String, email: String) {
    let db = Firestore.firestore()
    
    let data: [String: Any] = [
        "name": name,
        "lastName": lastName,
        "email": email,
    ]
    
    db.collection("users").addDocument(data: data) { error in
        if let error = error {
            print("Error writing document: \(error)")
        } else {
            print("Test successful!")
        }
    }
}

func saveJar(for userId: String) {
    let db = Firestore.firestore()
    
    let jarData: [String: Any] = [
        "name": "",
        "contents": [],
        "date": Date()
    ]
    
    db.collection("users")
      .document(userId)
      .collection("jars")
      .addDocument(data: jarData) { error in
          if let error = error {
              print("Error: \(error.localizedDescription)")
          } else {
              print("Jar saved!")
          }
      }
}
