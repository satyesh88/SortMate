import SwiftUI
import UIKit
import Foundation
import Combine
import FirebaseCore
import CryptoKit
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
      if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
                  CustomBundle.setLanguage(savedLanguage)
              } else {
                  CustomBundle.setLanguage("en") // Default to English if no preference is saved
              }
    return true
  }
}



class LanguageManager: ObservableObject {
    @Published var selectedLanguage: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en" {
        didSet {
            changeLanguage(to: selectedLanguage)
        }
    }
    
    private func changeLanguage(to language: String) {
        UserDefaults.standard.set(language, forKey: "selectedLanguage")
        CustomBundle.setLanguage(language)
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
}



struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var faceIDManager = FaceIDManager()
    @State private var email = ""
    @State private var password = ""
    @State private var fullname = ""
    @State private var isLoginMode = true
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isStaySignedIn = false

    var body: some View {
        VStack {
            Picker(selection: $languageManager.selectedLanguage, label: Text("")) {
                Text("English").tag("en")
                Text("Deutsch").tag("de")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if authViewModel.isAuthenticated || faceIDManager.isAuthenticated {
                MainView()
            } else {
                VStack {
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .cornerRadius(10)

                    Picker(selection: $isLoginMode, label: Text("")) {
                        Text(NSLocalizedString("login", comment: "")).tag(true)
                        Text(NSLocalizedString("sign_up", comment: "")).tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    if !isLoginMode {
                        TextField(NSLocalizedString("full_name", comment: ""), text: $fullname)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(5.0)
                    }

                    TextField(NSLocalizedString("email", comment: ""), text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(5.0)

                    SecureField(NSLocalizedString("password", comment: ""), text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(5.0)

                    Toggle(isOn: $isStaySignedIn) {
                        Text(NSLocalizedString("stay_signed_in", comment: ""))
                    }
                    .padding()

                    Button(action: {
                        if isLoginMode {
                            loginUser()
                        } else {
                            signupUser()
                        }
                    }) {
                        Text(isLoginMode ? NSLocalizedString("login", comment: "") : NSLocalizedString("sign_up", comment: ""))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(5.0)
                    }
                    .padding()
                    Button(action: {
                        authViewModel.authenticateWithFaceID { success, error in
                            if success {
                                faceIDManager.isAuthenticated = true
                            } else {
                                alertMessage = error ?? "Face ID authentication failed"
                                showingAlert = true
                            }
                        }
                    }) {
                        Text("Login with Face ID")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(5.0)
                    }
                    .padding()
                    Spacer()
                }
                .padding()
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
        .environmentObject(languageManager)
        .onAppear {
            // Load saved language preference
            if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
                languageManager.selectedLanguage = savedLanguage
            }
        }
    }

    private func loginUser() {
        authViewModel.login(email: email, password: password, staySignedIn: isStaySignedIn) { errorMessage in
            if let errorMessage = errorMessage {
                alertMessage = errorMessage
                showingAlert = true
            }
        }
    }

    private func signupUser() {
        authViewModel.signup(email: email, password: password, fullname: fullname, staySignedIn: isStaySignedIn) { errorMessage in
            if let errorMessage = errorMessage {
                alertMessage = errorMessage
                showingAlert = true
            } else {
                storeUserData(email: email, password: password, fullname: fullname)
            }
        }
    }

    private func storeUserData(email: String, password: String, fullname: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let encryptedPassword = encryptPassword(password: password)
        let userData = ["email": email, "password": encryptedPassword, "fullname": fullname]

        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(userData) { error in
            if let error = error {
                print("Error storing user data: \(error.localizedDescription)")
            }
        }
    }

    private func encryptPassword(password: String) -> String {
        let key = SymmetricKey(size: .bits256)
        let data = Data(password.utf8)
        let sealedBox = try! AES.GCM.seal(data, using: key)
        return sealedBox.combined!.base64EncodedString()
    }
}
