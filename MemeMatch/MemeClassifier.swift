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
        
        
        if features.smile < 0.006 {
            memes.append(MemeOption(name: "Mr. Incredible", assetName: "incredible"))
            memes.append(MemeOption(name: "Bad Luck Brian", assetName: "brian"))
            memes.append(MemeOption(name: "Hide the Pain Harold", assetName: "harold"))
        }
        
        
        else if features.smile >= 0.006 && features.smile < 0.02 {
            memes.append(MemeOption(name: "Kombucha Girl", assetName: "kombucha"))
            memes.append(MemeOption(name: "Side-Eye Chloe", assetName: "chloe"))
            memes.append(MemeOption(name: "Mewing", assetName: "mewing"))
        }
        
    
        else if features.smile >= 0.02 && features.smile < 0.03 {
            memes.append(MemeOption(name: "Gigachad", assetName: "chad"))
            memes.append(MemeOption(name: "The Rock Eyebrow", assetName: "rock"))
        }
        
    
        else if features.smile >= 0.03 {
            memes.append(MemeOption(name: "Confused Nick Young", assetName: "nick"))
        }
        
        
        else if features.eyeOpenness > 0.055 {
            memes.append(MemeOption(name: "Emotional Damage", assetName: "emotional"))
        }
        
        else {
            memes.append(contentsOf: [
                MemeOption(name: "Disgusted Gordon Ramsay", assetName: "gordon"),
        
            ])
        }
        
        
        return Array(memes.prefix(3))
    }
}



