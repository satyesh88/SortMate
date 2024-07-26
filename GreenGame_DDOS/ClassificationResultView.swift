//
//  ClassificationView.swift
//  GreenGame
//
//  Created by Satyesh Shivam on 18/06/24.
//

import Foundation

import SwiftUI

struct ClassificationResultView: View {
    var classifiedItems: [(item: String, bin: String)]
    var resultText: String

    var body: some View {
        VStack {
            Text("Classification Results")
                .font(.title)
                .padding()

            ScrollView {
                Text(resultText)
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.pink)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()

                ForEach(classifiedItems, id: \.item) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(item.item):")
                            Spacer()
                            Text(item.bin)
                            Image(getBinImageName(binType: item.bin))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        .padding()

                        if (item.item == ("Bottles (plastic)") || (item.item == "Aluminium foil and cans Bottle")){
                        VStack {
                        //Text("Please check if you have below image in the bottle. If yes, then take the bottle to recycling Centre of the Super Market. You will get money out of it.")
                        Text(NSLocalizedString("recycling_center_message", comment: ""))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.pink)
                        .padding()
                        Image("recycling_symbol")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                        }
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()

            Spacer()

            Button(action: {
                // Add any action if needed to close the view
            }) {
                Text("Done")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(5.0)
            }
            .padding()
        }
    }

    private func getBinImageName(binType: String) -> String {
        switch binType {
        case "RESTMÜLL":
            return "Rest"
        case "BIOMÜLL":
            return "BIO"
        case "YELLOW_BIN":
            return "Yellow"
        case "BLUE_BIN":
            return "Blue"
        default:
            return "Icon" // Add a default image name for unknown types
        }
    }
}
