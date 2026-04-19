import FirebaseFirestore

// Creates a new Jar and saves it to Firebase
func saveJar(for userId: String, name: String, goal: Double) {
    let db = Firestore.firestore()

    let jarData: [String: Any] = [
        "name": name,
        "balance": 0.0,
        "goal": goal,
        "date": Timestamp(date: Date())
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
