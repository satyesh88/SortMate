//
//  LocalAuthentication.swift
//  GreenGame
//
//  Created by Satyesh Shivam on 20/06/24.
//

import LocalAuthentication
import SwiftUI

class FaceIDManager: ObservableObject {
    @Published var isAuthenticated = false
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to continue."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                        NotificationCenter.default.post(name: .authenticatedWithFaceID, object: nil) // Notify AuthViewModel
                    } else {
                        self.isAuthenticated = false
                    }
                }
            }
        } else {
            // No biometrics
            self.isAuthenticated = false
        }
    }
}

extension Notification.Name {
    static let authenticatedWithFaceID = Notification.Name("authenticatedWithFaceID")
}
   
