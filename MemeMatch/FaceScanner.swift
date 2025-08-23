//
//  StillImageViewController.swift
//  MemeMatch
//
//  Created by Aletheus Ang on 23/8/25.
//

import UIKit
import Vision

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let scale = width / self.size.width
        let height = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

struct FaceScanner {
    static func detectFaces(in image: UIImage, completion: @escaping ([VNFaceObservation]) -> Void) {
        // Resize the image first
        guard let resizedImage = image.resized(toWidth: 500),
              let cgImage = resizedImage.cgImage else {
            completion([])
            return
        }
        
        let request = VNDetectFaceLandmarksRequest { request, error in
            guard let results = request.results as? [VNFaceObservation] else {
                completion([])
                return
            }
            completion(results)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
