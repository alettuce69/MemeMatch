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
        guard let cgImage = image.cgImage else {
            print("FaceCropper: invalid input image")
            completion(nil, nil)
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                print("FaceCropper: VN request error:", error.localizedDescription)
                completion(nil, nil)
                return
            }
            
            guard let results = request.results as? [VNFaceObservation],
                  let firstFace = results.first else {
                print("FaceCropper: no faces detected")
                completion(nil, nil)
                return
            }
            
           
            let boundingBox = firstFace.boundingBox
            let imgW = CGFloat(cgImage.width)
            let imgH = CGFloat(cgImage.height)
            
            let faceRect = CGRect(
                x: boundingBox.origin.x * imgW,
                y: (1 - boundingBox.origin.y - boundingBox.height) * imgH,
                width: boundingBox.width * imgW,
                height: boundingBox.height * imgH
            ).integral
            
            guard let croppedCG = cgImage.cropping(to: faceRect) else {
                print("FaceCropper: cropping failed for rect:", faceRect)
                completion(nil, nil)
                return
            }
            
            let croppedImage = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
            completion(croppedImage, faceRect)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("FaceCropper: handler.perform error:", error.localizedDescription)
            completion(nil, nil)
        }
    }
}

