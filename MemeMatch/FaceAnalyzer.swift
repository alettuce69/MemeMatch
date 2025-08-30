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
            
            // Smile score
            var smileScore: CGFloat = 0
            if let outer = lm?.outerLips?.normalizedPoints, outer.count > 6 {
                let left = outer[0]
                let right = outer[6]
                smileScore = max(0, (right.x - left.x) * abs(right.y - left.y))
            }
            
            // Eye openness score (left eye as reference)
            var eyeScore: CGFloat = 0
            if let leftEye = lm?.leftEye?.normalizedPoints, leftEye.count > 5 {
                let top = leftEye[1].y
                let bottom = leftEye[5].y
                eyeScore = max(0, abs(top - bottom))
            }
            
            let neutrality = max(0, 1 - smileScore)
            
            // Face bounding box in image coordinates
            let bbox = face.boundingBox
            let imgW = CGFloat(cg.width)
            let imgH = CGFloat(cg.height)
            let cropRect = CGRect(
                x: bbox.origin.x * imgW,
                y: (1 - bbox.origin.y - bbox.height) * imgH,
                width: bbox.width * imgW,
                height: bbox.height * imgH
            ).integral
            
            // Crop and mask into circular image with transparent background
            var croppedImage: UIImage? = nil
            if let croppedCG = cg.cropping(to: cropRect) {
                let rect = CGRect(origin: .zero, size: CGSize(width: cropRect.width, height: cropRect.height))
                let renderer = UIGraphicsImageRenderer(size: rect.size)
                croppedImage = renderer.image { ctx in
                    // Clear background for transparency
                    ctx.cgContext.clear(rect)
                    
                    // Clip to circle
                    let circlePath = UIBezierPath(ovalIn: rect)
                    circlePath.addClip()
                    
                    // Draw face
                    UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
                        .draw(in: rect)
                }
                print("FaceAnalyzer: circular face with transparent background size: \(String(describing: croppedImage?.size))")
            } else {
                print("FaceAnalyzer: cropping failed for rect: \(cropRect)")
            }
            
            let features = FaceFeatures(smile: smileScore, eyeOpenness: eyeScore, neutrality: neutrality)
            completion(features, croppedImage, bbox)
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
