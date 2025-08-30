//
//  MemeClassifier.swift
//  MemeMatch
//
//  Created by Gautham Dinakaran on 29/8/25.
//

import Foundation
import UIKit

public struct MemeOption: Identifiable {
    public let id = UUID()
    public let name: String
    public let assetName: String
}

public class MemeClassifier {
   
    public static func classify(features: FaceFeatures) -> [MemeOption] {
        var memes: [MemeOption] = []
        
        
//        if features.smile > 0.00 && features.eyeOpenness > 0.00 {
//            memes.append(contentsOf: [
//                MemeOption(name: "Shocked", assetName: "shocked"),
            
//            ])
          if features.neutrality > 100 {
            
            memes.append(contentsOf: [
                MemeOption(name: "Mr. Incredible", assetName: "incredible")
            ])
            
        } else if features.smile < 0.0 && features.eyeOpenness < 0.00 {
            memes.append(contentsOf: [
                MemeOption(name: "Test", assetName: "mewing"),
            ])
        } else {
           
            memes.append(contentsOf: [
                MemeOption(name: "Mewing", assetName: "incredible"),
                MemeOption(name: "Shrek", assetName: "shrek"),
        
            ])
        }
        
        
        return Array(memes.prefix(3))
    }
}



