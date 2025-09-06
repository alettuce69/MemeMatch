//
//  MemeOverlayView.swift
//  MemeMatch
//
//  Created by Gautham Dinakaran on 29/8/25.
//

import SwiftUI
import UIKit

struct MemeOverlayView: View {
   
    let userFace: UIImage
    let memes: [MemeOption]
    @State private var composedImages: [UIImage] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                
                Text("Pick one to share")
                    .font(.headline)
                    .padding(.top, 8)
                
                ForEach(Array(zip(memes.indices, memes)), id: \.1.id) { index, meme in
                    VStack(spacing: 8) {
                        Text(meme.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        if composedImages.indices.contains(index) {
                            Image(uiImage: composedImages[index])
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .padding(.horizontal, 12)
                        } else {
                           
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 220)
                                .overlay(Text("Preparing..."))
                                .padding(.horizontal, 12)
                        }
                        
                        HStack {
                            Button("Share") {
                                if composedImages.indices.contains(index) {
                                    shareImage(composedImages[index])
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            
                            
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .onAppear {
             
                composeAll()
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Choose Your Meme")
    }
    

    private func composeAll() {

        DispatchQueue.global(qos: .userInitiated).async {
            var results: [UIImage] = []
            for meme in memes {
                if let composed = compose(templateName: meme.assetName, face: userFace) {
                    results.append(composed)
                    print("MemeOverlayView: composed for template '\(meme.assetName)' size=\(composed.size)")
                } else {
                    print("MemeOverlayView: failed to compose template '\(meme.assetName)'")

                    let blank = UIImage(systemName: "xmark.octagon") ?? UIImage()
                    results.append(blank)
                }
            }
            DispatchQueue.main.async {
                self.composedImages = results
            }
        }
    }
    
    
    private func compose(templateName: String, face: UIImage) -> UIImage? {
        guard let template = UIImage(named: templateName) else {
            print("compose: template '\(templateName)' not found in assets")
            return nil
        }
        
        let tplSize = template.size
        UIGraphicsBeginImageContextWithOptions(tplSize, false, template.scale)
        defer { UIGraphicsEndImageContext() }
        
        
        template.draw(in: CGRect(origin: .zero, size: tplSize))
        
        
        let faceWidth = tplSize.width * 0.45
        let faceHeight = faceWidth * (face.size.height / max(face.size.width, 1))
        
       
        let centerX = tplSize.width * 0.52
        let centerY = tplSize.height * 0.54
        
        let destRect = CGRect(x: centerX - faceWidth/2, y: centerY - faceHeight/2, width: faceWidth, height: faceHeight)
        
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        
        let circlePath = UIBezierPath(ovalIn: destRect.insetBy(dx: -4, dy: -4))
        circlePath.addClip()
        
       
        face.draw(in: destRect, blendMode: .normal, alpha: 0.90)
        
        ctx?.restoreGState()
        
        
        let strokePath = UIBezierPath(ovalIn: destRect)
        UIColor(white: 0.0, alpha: 0.12).setStroke()
        strokePath.lineWidth = 2
        strokePath.stroke()
        

        let composed = UIGraphicsGetImageFromCurrentImageContext()
        return composed
    }
    
    // MARK: - Share helper
    private func shareImage(_ image: UIImage) {
        guard let data = image.pngData() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("meme.png")
        try? data.write(to: url)
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let root = UIApplication.shared.windows.first?.rootViewController {
            root.present(vc, animated: true, completion: nil)
        } else {
            print("shareImage: couldn't find root view controller")
        }
    }
}
