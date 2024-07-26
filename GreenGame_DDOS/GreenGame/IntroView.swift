//
//  IntroView.swift
//  GreenGame
//
//  Created by Satyesh Shivam on 13/07/24.
//

import SwiftUI

struct IntroView: View {
    @Binding var isIntroActive: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("Separate Your Trash Easily")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            Spacer()
            Image("Intro")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Spacer()
            
            Text("This app helps you classify waste items into the correct bins, making recycling easier and more effective.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: {
                isIntroActive = false
            }) {
                Text("Get Started")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)

    }
}

