import FirebaseFirestore

// Uses firebase frame work to start a new collection
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
