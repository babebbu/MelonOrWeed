//
//  ContentView.swift
//  PlantDiseaseClassifier
//
//  Created by Babebbu on 14/9/2565 BE.
//

import SwiftUI
import PhotosUI
import CoreML
import Vision

struct ContentView: View {
    
    /// A predictor instance that uses Vision and Core ML to generate prediction strings from a photo.
    let imagePredictor = ImagePredictor()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var uiImage: UIImage? = nil
    @State private var label: String? = nil
    
    var body: some View {
        
        Text("Melon or Weed?").bold().font(.system(size: 36)).padding(.bottom, 1)
        
        // Output
        if let label {
            Text(label)
                .font(.system(size: 24))
        }
        
        // Selected Image
        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        }
        
        // Photo Picker
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            HStack {
                Image(systemName: "photo")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Select a photo")
            }
            .padding()
        }.onChange(of: selectedItem) {
            newItem in Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    uiImage = UIImage(data: data)
                    classify()
                }
            }
        }
    }
    
    private func setLabel(text: String) {
        label = text
    }
    
    private func classify() {
        print("Begin Classification")
        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
            print("Image Selected")
            do {
                let start = CFAbsoluteTimeGetCurrent()
                try imagePredictor.makePredictions(for: uiImage, completionHandler: imagePredictionHandler)
                let diff = CFAbsoluteTimeGetCurrent() - start
                print("Time Elapsed: \(diff)")
            } catch {
                print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
            }
        }
    }
    
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        print("Handler has been called.")
        guard let predictions = predictions else {
            setLabel(text: "Don't Know, See Console.")
            return
        }
        
        print("Prediction Results")
        for prediction in predictions {
            print(prediction)
        }
        
        if let prediction = predictions.first {
            setLabel(text: "\(prediction.classification.capitalized) (\(prediction.confidence * 100)%)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
