//
//  ContentView.swift
//  MemeMatch
//
//  Created by Aletheus Ang on 16/8/25.
//

import SwiftUI
import PhotosUI
import Vision
import UIKit

struct FaceFeatures {
    var smileScore: Float
    var jawlineSharpness: Float
    var eyeOpenness: Float
}


class FaceAnalyzer {
    func analyzeFace(from image: UIImage, completion: @escaping ([FaceFeatures]) -> Void) {
        guard let cgImage = image.cgImage else { return }
        
        _ = VNDetectFaceLandmarksRequest { request, error in
            guard let results = request.results as? [VNFaceObservation] else { return }
            
            var featuresArray: [FaceFeatures] = []
            
            for face in results {
                var smileScore: Float = 0
                var jawlineSharpness: Float = 0
                var eyeOpenness: Float = 0
                
                if face.landmarks != nil {
                    // Smile score = ratio of mouth width / height
                    if let landmarks = face.landmarks {
                        
                        if let mouth = landmarks.outerLips, mouth.pointCount > 3 {
                            let top = mouth.normalizedPoints[0]
                            let bottom = mouth.normalizedPoints[mouth.pointCount / 2]
                            let left = mouth.normalizedPoints.first!
                            let right = mouth.normalizedPoints.last!
                            let width = hypot(right.x - left.x, right.y - left.y)
                            let height = hypot(top.x - bottom.x, top.y - bottom.y)
                            if height > 0 {
                                smileScore = Float(width / height)
                            }
                        }
                        
                        // Jawline sharpness = ratio of jaw width / jaw height
                        if let contour = landmarks.faceContour, contour.pointCount > 5 {
                            let chin = contour.normalizedPoints[0]
                            let left = contour.normalizedPoints[2]
                            let right = contour.normalizedPoints[contour.pointCount - 3]
                            let faceWidth = hypot(left.x - right.x, left.y - right.y)
                            let faceHeight = hypot(chin.x - (left.x+right.x)/2,
                                                   chin.y - (left.y+right.y)/2)
                            if faceHeight > 0 {
                                jawlineSharpness = Float(faceWidth / faceHeight)
                            }
                        }
                        
                        
                        // Eye openness = vertical eyelid distance
                        if let leftEye = landmarks.leftEye, leftEye.pointCount > 4 {
                            let top = leftEye.normalizedPoints[1]
                            let bottom = leftEye.normalizedPoints[4]
                            eyeOpenness = Float(hypot(top.x - bottom.x, top.y - bottom.y))
                        }
                    }
                    
                    let features = FaceFeatures(
                        smileScore: smileScore,
                        jawlineSharpness: jawlineSharpness,
                        eyeOpenness: eyeOpenness
                    )
                    featuresArray.append(features)
                }
                
                completion(featuresArray)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
    
    
    struct ContentView: View {
        @State private var selectedItem: PhotosPickerItem? = nil
        @State private var selectedImage: UIImage? = nil
        @State private var features: [FaceFeatures] = []   // detected features
        
        private let analyzer = FaceAnalyzer()
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Meme Match")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                        .padding()
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .foregroundColor(.gray)
                        .frame(width: 250, height: 250)
                        .overlay(
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        )
                }
                
                // Pick a photo
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Pick a Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .onChange(of: selectedItem) { newItem in
                    if let newItem {
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                
                                selectedImage = uiImage
                                
                                // 🔥 Analyze the face
                                analyzer.analyzeFace(from: uiImage) { result in
                                    DispatchQueue.main.async {
                                        self.features = result
                                        print("Analysis result: \(result)")
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Debug output of scores
                if !features.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(features.indices, id: \.self) { i in
                            Text("Face \(i+1): 😀Smile \(features[i].smileScore, specifier: "%.2f"), 🪞Jaw \(features[i].jawlineSharpness, specifier: "%.2f"), 👁Eye \(features[i].eyeOpenness, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    #Preview {
        ContentView()
    }
}

