//
//  MainView.swift
//  GreenGame
//
//  Created by Satyesh Shivam on 14/06/24.
//
import SwiftUI
import AVFoundation
import FirebaseAnalytics

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var classifier = ImageClassifier()
    @State private var showingImagePicker = false
    @State private var errorMessage: String?
    @State private var isClassifying = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingSourceTypeSelection = false
    @State private var classificationAmount: Double = 0
    @State private var timer: Timer?
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            HStack {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                    .padding()
            }
            
            HStack {
                if let image = classifier.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
                Button(action: {
                    showingSourceTypeSelection = true
                }) {
                    Text(NSLocalizedString("upload_image", comment: ""))
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            
            if isClassifying {
                ProgressView(NSLocalizedString("classifying", comment: ""), value: classificationAmount, total: 100)
                    .padding()
            } else {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                ScrollView {
                    ForEach(classifier.classifiedItems, id: \.item) { item in
                        VStack {
                            HStack {
                                Text("\(item.item): \(item.bin)")
                                    .onAppear() {
                                        logClassificationEvent(item: item.item, bin: item.bin)
                                        let message = ("\(item.item) should go to \(item.bin)")
                                        speak(message)
                                        
                                    }
                                Image(getBinImageName(binType: item.bin))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            }
                            .padding()
                            if (item.item == "Bottles (plastic)" || item.item == "Aluminium foil and cans Bottle") {
                                VStack {
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
                                .onAppear {
                                    let message = NSLocalizedString("recycling_center_message", comment: "")
                                    speak(message)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .frame(maxHeight: 400) // Adjust the height as needed
                .padding()
            }
            
            Spacer()
            Button(action: {
                authViewModel.logout()
            }) {
                Text(NSLocalizedString("logout", comment: ""))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(5.0)
            }
            .padding()
        }
        .actionSheet(isPresented: $showingSourceTypeSelection) {
            ActionSheet(
                title: Text(NSLocalizedString("select_image", comment: "")),
                message: Text(NSLocalizedString("img_source", comment: "")),
                buttons: [
                    .default(Text("Camera")) {
                        imagePickerSourceType = .camera
                        showingImagePicker = true
                    },
                    .default(Text("Photo Library")) {
                        imagePickerSourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $classifier.image, sourceType: imagePickerSourceType)
                .onChange(of: classifier.image) {
                    classifyImage()
                }
        }
        .onChange(of: classifier.image) {
            classifyImage()
        }
        .onAppear {
            checkCameraAccess()
        }
        
        
    }

/*
    private func classifyImage() {
        isClassifying = true
        errorMessage = nil
        classificationAmount = 0

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            if classificationAmount < 100 {
                classificationAmount += 2
            }
        }

        classifier.classifyImage { result in
            timer?.invalidate()
            isClassifying = false
            if let classificationText = result {
                _ = classifier.determineBinType(classificationText: classificationText)
            } else {
                errorMessage = "Unable to classify the image. Can you re-upload the image?"
            }
        }
    }*/
    private func classifyImage() {
            isClassifying = true
            errorMessage = nil
            classificationAmount = 0

            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                if classificationAmount < 100 {
                    classificationAmount += 2
                }
            }

            ImageUploadManager.shared.canUploadImage { canUpload, error in
                if canUpload {
                    classifier.classifyImage { result in
                        timer?.invalidate()
                        isClassifying = false
                        if let classificationText = result {
                            _ = classifier.determineBinType(classificationText: classificationText)
                            ImageUploadManager.shared.incrementUploadCount { success in
                                if !success {
                                    errorMessage = "Error recording upload count"
                                }
                            }
                        } else {
                            errorMessage = "Unable to classify the image. Can you re-upload the image?"
                        }
                    }
                } else {
                    timer?.invalidate()
                    isClassifying = false
                    errorMessage = error ?? "Upload limit reached. Please try again tomorrow."
                }
            }
        }
    
    private func logClassificationEvent(item: String, bin: String) {
            Analytics.logEvent("classification_event", parameters: [
                "item": item as NSObject,
                "bin": bin as NSObject
            ])
        }
    
    private func getBinImageName(binType: String) -> String {
        switch binType {
        case "RESTMULL":
            return "Rest"
        case "BIOMULL":
            return "BIO"
        case "YELLOW_BIN":
            return "Yellow"
        case "BLUE_BIN":
            return "Blue"
        default:
            return "Icon" // Add a default image name for unknown types
        }
    }
    
    private func checkCameraAccess(completion: @escaping () -> Void = {}) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        completion()
                    } else {
                        errorMessage = "Camera access is required to take photos."
                    }
                }
            }
        case .denied, .restricted:
            errorMessage = "Camera access is required to take photos. Please update your settings."
        @unknown default:
            errorMessage = "An unknown error occurred while requesting camera access."
        }
    }
    func speak(_ text: String) {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            speechSynthesizer.speak(utterance)
        }
}
