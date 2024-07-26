import SwiftUI
import Foundation
import CoreImage
import UIKit

class ImageClassifier: ObservableObject {
    @Published var image: UIImage?
    @Published var resultText: String = ""
    @Published var classifiedItems: [(item: String, bin: String)] = []
    
    let referenceImage = UIImage(named: "recycling_symbol")
    

    func classifyImage(completion: @escaping (String?) -> Void) {
        ImageUploadManager.shared.canUploadImage { [weak self] (canUpload, error) in
            guard let self = self else { return }
            if canUpload {
                self.performImageClassification { result in
                    if result != nil {
                        ImageUploadManager.shared.incrementUploadCount { success in
                            if success {
                                completion(result)
                            } else {
                                completion("Error recording upload count1")
                            }
                        }
                    } else {
                        completion("Classification failed")
                    }
                }
            } else {
                self.resultText = error ?? "Upload limit reached"
                completion(nil)
            }
        }
    }
    private func performImageClassification(completion: @escaping (String?) -> Void) {
        self.resultText = ""
        self.classifiedItems = []
        guard let image = image, let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let base64Image = imageData.base64EncodedString()
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        let contentUser: [[String: Any]] = [
            ["type": "text", "text": "This is an image of a trash item. Describe this image, and then classify it in Classes :\(ALL_CLASSES). If the image contains inappropriate content, respond with a warning message."],
            ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
        ]

        let contentSystem: [[String: Any]] = [
            ["type": "text", "text": "You are an assistant trained to describe images of trash. If the image contains inappropriate content, respond with a warning message. Classes: \(ALL_CLASSES)."]
        ]

        let payload: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": contentSystem],
                ["role": "user", "content": contentUser]
            ],
            "max_tokens": 300,
            "temperature": 0.7
        ]

        let url = URL(string: apiBase)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            do {
                if let classification = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = classification["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        if content.lowercased().contains("inappropriate content") {
                                                    self.resultText = "Warning: The image contains inappropriate content and cannot be classified."
                                                } else {
                                                    self.resultText = content
                                                }
                        completion(content)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
        }
    func determineBinType(classificationText: String) -> [(item: String, bin: String)] {
        var classifiedItems: [(item: String, bin: String)] = []

        for cls in ALL_CLASSES {
            if classificationText.lowercased().contains(cls.lowercased()) {
                let binType: String
                if RESTMULL_CLASSES.contains(cls) {
                    binType = "RESTMULL"
                } else if BIO_BIN_CLASSES.contains(cls) {
                    binType = "BIOMULL"
                } else if YELLOW_MULL.contains(cls) {
                    binType = "YELLOW_BIN"
                } else if BLUE_PAPER_MULL.contains(cls) {
                    binType = "BLUE_BIN"
                } else {
                    binType = "Unknown"
                }
                classifiedItems.append((item: cls, bin: binType))
            }
        }

        self.classifiedItems = classifiedItems

        if classifiedItems.isEmpty {
            resultText = "Unable to determine the bin type. Can you re-upload the image?"
        } else {
            resultText = "Classification Results:"
            for item in classifiedItems {
                resultText += "\n- \(item.item): \(item.bin)"
            }
        }

        return classifiedItems
    }
}

