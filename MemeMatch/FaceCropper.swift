//
//  FaceCropper.swift
//  MemeMatch
//
//  Created by Gautham Dinakaran on 8/9/25.
//
import Foundation
import Vision
import UIKit

public class FaceCropper {
    public static func cropFace(from image: UIImage, completion: @escaping (UIImage?, CGRect?) -> Void) {
        guard let cg = image.cgImage else {
            print("FaceCropper: image has no cgImage")
            completion(nil, nil)
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let err = error {
                print("FaceCropper: VN request error:", err.localizedDescription)
                completion(nil, nil)
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation],
                  let firstFace = observations.first else {
                print("FaceCropper: no faces detected")
                completion(nil, nil)
                return
            }
            
            // Convert normalized rect (0–1) into pixel coordinates
            let boundingBox = firstFace.boundingBox
            let width = CGFloat(cg.width)
            let height = CGFloat(cg.height)
            let rect = CGRect(
                x: boundingBox.origin.x * width,
                y: (1 - boundingBox.origin.y - boundingBox.height) * height,
                width: boundingBox.width * width,
                height: boundingBox.height * height
            )
            
            // Crop face region
            if let croppedCG = cg.cropping(to: rect) {
                let croppedImage = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
                print("FaceCropper: Cropped face rect = \(rect)")
                completion(croppedImage, rect)
            } else {
                print("FaceCropper: cropping failed")
                completion(nil, nil)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("FaceCropper: handler.perform error:", error.localizedDescription)
            completion(nil, nil)
        }
    }
}
