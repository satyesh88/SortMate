import SwiftUI
import FirebaseAuth
import LocalAuthentication

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    private var handle: AuthStateDidChangeListenerHandle?
    

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
        }
        checkIfLoggedIn()
    }

    func login(email: String, password: String, staySignedIn: Bool, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            if staySignedIn {
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(password, forKey: "password")
                UserDefaults.standard.set(true, forKey: "staySignedIn")
                UserDefaults.standard.set(true, forKey: "useFaceID")
                print("Credentials stored during login: email=\(email), password=\(password)")
            } else {
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "password")
                UserDefaults.standard.set(false, forKey: "staySignedIn")
                UserDefaults.standard.set(false, forKey: "useFaceID")
            }
            self?.isAuthenticated = true
            completion(nil)
        }
    }

    func signup(email: String, password: String, fullname: String, staySignedIn: Bool, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            if staySignedIn {
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(password, forKey: "password")
                UserDefaults.standard.set(true, forKey: "staySignedIn")
                UserDefaults.standard.set(true, forKey: "useFaceID")
                print("Credentials stored during signup: email=\(email), password=\(password)")
            } else {
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "password")
                UserDefaults.standard.set(false, forKey: "staySignedIn")
                UserDefaults.standard.set(false, forKey: "useFaceID")
            }
            self?.isAuthenticated = true
            completion(nil)
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            let useFaceID = UserDefaults.standard.bool(forKey: "useFaceID")
            if !useFaceID {
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "password")
                UserDefaults.standard.set(false, forKey: "staySignedIn")
                UserDefaults.standard.set(false, forKey: "useFaceID")
            }
            print("Logged out. Credentials removed: \(useFaceID ? "No" : "Yes")")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func authenticateWithFaceID(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Face ID to access your account"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        let isUserRegistered = UserDefaults.standard.bool(forKey: "isUserRegistered")
                        if isUserRegistered {
                            self?.signInWithStoredCredentials(completion: completion)
                        } else {
                            completion(false, "You need to sign up first before using Face ID.")
                        }
                    } else {

                        completion(false, "Face ID authentication failed")
                    }
                }
            }
        } else {
            completion(false, "Face ID not available")
        }
    }

    private func signInWithStoredCredentials(completion: @escaping (Bool, String?) -> Void) {
        guard let email = UserDefaults.standard.string(forKey: "email"),
              let password = UserDefaults.standard.string(forKey: "password") else {
            completion(false, "Stored credentials not found")
            return
        }

        print("Retrieved stored credentials: email=\(email), password=\(password)")

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                self?.isAuthenticated = true
                completion(true, nil)
            }
        }
    }

    private func checkIfLoggedIn() {
        let staySignedIn = UserDefaults.standard.bool(forKey: "staySignedIn")
        if staySignedIn, Auth.auth().currentUser != nil {
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
}
