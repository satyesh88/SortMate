/*import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false

    var body: some View {
        VStack {
            
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            Text("Welcome to SortMate")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
        }
    }
}*/

import SwiftUI

struct SplashScreenView: View {
    @State private var isSplashActive = true
    @State private var isIntroActive = true

    var body: some View {
        VStack {
            if isSplashActive {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Group{
                    Text("Sort")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .fontWeight(.bold) +
                    Text("Mate")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                    
                }
               
            } else if isIntroActive {
                IntroView(isIntroActive: $isIntroActive)
            } else {
                ContentView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isSplashActive = false
            }
        }
    }
}


