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
        
        let faceRequest = VNDetectFaceLandmarksRequest { request, error in
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
            
            // --- Landmark feature extraction ---
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
            
            // --- Face bounding box (for alignment) ---
            let bbox = face.boundingBox
            let imgW = CGFloat(cg.width)
            let imgH = CGFloat(cg.height)
            let cropRect = CGRect(
                x: bbox.origin.x * imgW,
                y: (1 - bbox.origin.y - bbox.height) * imgH,
                width: bbox.width * imgW,
                height: bbox.height * imgH
            ).integral
            
            // --- DeepLab v3 segmentation for clean crop ---
            let segmentationRequest = VNGeneratePersonSegmentationRequest()
            segmentationRequest.qualityLevel = .accurate
            segmentationRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
            
            let cgOrientation: CGImagePropertyOrientation
            switch image.imageOrientation {
            case .up: cgOrientation = .up
            case .down: cgOrientation = .down
            case .left: cgOrientation = .left
            case .right: cgOrientation = .right
            case .upMirrored: cgOrientation = .upMirrored
            case .downMirrored: cgOrientation = .downMirrored
            case .leftMirrored: cgOrientation = .leftMirrored
            case .rightMirrored: cgOrientation = .rightMirrored
            @unknown default: cgOrientation = .up
            }
            let handler = VNImageRequestHandler(cgImage: cg, orientation: cgOrientation, options: [:])

            
            do {
                try handler.perform([segmentationRequest])
            } catch {
                print("FaceAnalyzer: segmentation failed:", error.localizedDescription)
                completion(features, image, bbox) // fallback to original image
                return
            }
            
            guard let maskBuffer = segmentationRequest.results?.first?.pixelBuffer else {
                print("FaceAnalyzer: no segmentation mask found")
                completion(features, image, bbox) // fallback
                return
            }
            
            // Convert segmentation mask into UIImage
            let maskCI = CIImage(cvPixelBuffer: maskBuffer)
            let maskScaled = maskCI.transformed(by: CGAffineTransform(scaleX: image.size.width / maskCI.extent.width,
                                                                      y: image.size.height / maskCI.extent.height))
            
            guard let maskCG = CIContext().createCGImage(maskScaled, from: maskScaled.extent) else {
                print("FaceAnalyzer: mask conversion failed")
                completion(features, image, bbox)
                return
            }
            
            let maskUIImage = UIImage(cgImage: maskCG, scale: image.scale, orientation: image.imageOrientation)
            
            // Apply mask to original image
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            guard let ctx = UIGraphicsGetCurrentContext() else {
                completion(features, image, bbox)
                return
            }
            
            // Draw background transparent
            ctx.translateBy(x: 0, y: image.size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            
            let rect = CGRect(origin: .zero, size: image.size)
            ctx.clip(to: rect, mask: maskCG)
            ctx.draw(cg, in: rect)
            
            let segmentedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Final crop to face bounding box (but from segmented version)
            var finalFace: UIImage? = segmentedImage
            if let segCG = segmentedImage?.cgImage, let croppedCG = segCG.cropping(to: cropRect) {
                finalFace = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
            }
            
            if finalFace == nil {
                print("FaceAnalyzer: crop from segmentation failed, using whole segmented image")
                finalFace = segmentedImage ?? image
            }
            
            completion(features, finalFace, bbox)
        }
        
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        do {
            try handler.perform([faceRequest])
        } catch {
            print("FaceAnalyzer: handler.perform error:", error.localizedDescription)
            completion(nil, nil, nil)
        }
    }
}

