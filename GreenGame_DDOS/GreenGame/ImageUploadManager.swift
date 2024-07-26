import FirebaseFirestore
import FirebaseAuth

class ImageUploadManager {
    static let shared = ImageUploadManager()
    private let db = Firestore.firestore()
    private let dailyUploadLimit = 50

    func canUploadImage(completion: @escaping (Bool, String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, "User not authenticated")
            return
        }

        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)

        let docRef = db.collection("users").document(userId).collection("uploads").document(todayString)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(false, "Error fetching upload data")
                return
            }

            if let document = document, document.exists {
                if let data = document.data(), let count = data["count"] as? Int {
                    if count >= self.dailyUploadLimit {
                        completion(false, nil)
                    } else {
                        completion(true, nil)
                    }
                } else {
                    completion(true, nil)
                }
            } else {
                completion(true, nil)
            }
        }
    }

    func incrementUploadCount(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)

        let docRef = db.collection("users").document(userId).collection("uploads").document(todayString)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                print("Error fetching document: \(fetchError)")
                errorPointer?.pointee = fetchError
                return nil
            }

            let newCount: Int
            if let count = document.data()?["count"] as? Int {
                newCount = count + 1
            } else {
                newCount = 1
            }

            transaction.setData(["count": newCount], forDocument: docRef, merge: true)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Error incrementing count: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
