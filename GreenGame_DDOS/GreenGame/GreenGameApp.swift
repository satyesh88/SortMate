//
//  GreenGameApp.swift
//  GreenGame
//
//  Created by Satyesh Shivam on 11/06/24.
//

import SwiftUI
import Firebase

@main
struct GreenGameApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()


    var body: some Scene {
        WindowGroup {
            //ContentView()
            SplashScreenView()
                .environmentObject(authViewModel)
        }
    }
}
