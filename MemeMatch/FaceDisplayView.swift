//
//  FaceDisplayView.swift
//  MemeMatch
//
//  Created by Aletheus Ang on 23/8/25.
//

import SwiftUI
import Vision

struct FaceDisplayView: View {
    let image: UIImage
    let faces: [VNFaceObservation]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                
                // Draw bounding boxes
                ForEach(faces.indices, id: \.self) { i in
                    BoundingBox(face: faces[i], in: geo.size)
                }
            }
        }
    }
}

struct BoundingBox: View {
    let face: VNFaceObservation
    let size: CGSize
    
    init(face: VNFaceObservation, in size: CGSize) {
        self.face = face
        self.size = size
    }
    
    var body: some View {
        let rect = CGRect(
            x: face.boundingBox.origin.x * size.width,
            y: (1 - face.boundingBox.origin.y - face.boundingBox.height) * size.height,
            width: face.boundingBox.width * size.width,
            height: face.boundingBox.height * size.height
        )
        
        return RoundedRectangle(cornerRadius: 6)
            .stroke(Color.red, lineWidth: 2)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}
