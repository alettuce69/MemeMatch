//
//  FaceAnalyzer.swift
//  MemeMatch
//
//  Created by Gautham Dinakaran on 29/8/25.
import Foundation
import Vision
import UIKit

public struct FaceFeatures {
    public let smile: CGFloat
    public let eyeOpenness: CGFloat
    public let neutrality: CGFloat
}

public class FaceAnalyzer {
    public static func analyzeFace(from image: UIImage, completion: @escaping (FaceFeatures?, UIImage?, CGRect?) -> Void) {
        guard let cg = image.cgImage else {
            print("FaceAnalyzer: image has no cgImage")
            completion(nil, nil, nil)
            return
        }
        
        let request = VNDetectFaceLandmarksRequest { request, error in
            if let err = error {
                print("FaceAnalyzer: VN request error:", err.localizedDescription)
                completion(nil, nil, nil)
                return
            }
            guard let obs = request.results as? [VNFaceObservation], let face = obs.first else {
                print("FaceAnalyzer: no face observations")
                completion(nil, nil, nil)
                return
            }
            
           
            let lm = face.landmarks
            var smileScore: CGFloat = 0
            if let outer = lm?.outerLips?.normalizedPoints, outer.count > 6 {
                let left = outer[0]
                let right = outer[6]
                smileScore = max(0, (right.x - left.x) * abs(right.y - left.y))
            }
            
           
            var eyeScore: CGFloat = 0
            if let leftEye = lm?.leftEye?.normalizedPoints, leftEye.count > 5 {
                let top = leftEye[1].y
                let bottom = leftEye[5].y
                eyeScore = max(0, abs(top - bottom))
            }
            
            let neutrality = max(0, 1 - smileScore)
            
            let features = FaceFeatures(smile: smileScore, eyeOpenness: eyeScore, neutrality: neutrality)
            completion(features, nil, nil)
            print(features)
        }
        
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("FaceAnalyzer: handler.perform error:", error.localizedDescription)
            completion(nil, nil, nil)
        }
    }
}
    
