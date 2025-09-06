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
        
        

        let targets: [(FaceFeatures, String, String)] = [
            (FaceFeatures(smile: 0.030710333234644338, eyeOpenness: 0.03102552890777588, neutrality: 0.9683354367195074), "Nick", "nick"),
            (FaceFeatures(smile: 0.020230598723594895, eyeOpenness: 0.05759787559509277, neutrality: 0.9915059745307211), "Rock", "rock"),
            (FaceFeatures(smile: 0.0023922454328957343, eyeOpenness: 0.04040861129760742, neutrality: 0.9976077545671043), "Brian", "brian"),
            (FaceFeatures(smile: 0.025837149412479832, eyeOpenness: 0.038410067558288574, neutrality: 0.9741628505875202), "Chad", "chad"),
            (FaceFeatures(smile: 0.013125080695189695, eyeOpenness: 0.05819755792617798, neutrality: 0.9868749193048103), "Chloe", "chloe"),
            (FaceFeatures(smile: 0.005071301578482235, eyeOpenness: 0.053470492362976074, neutrality: 0.9949286984215178), "Emotional", "emotional"),
            (FaceFeatures(smile: 0.007959514647454036, eyeOpenness: 0.03626859188079834, neutrality: 0.992040485352546), "Harold", "harold"),
            (FaceFeatures(smile: 0.00048242729531189354, eyeOpenness: 0.05703479051589966, neutrality: 0.9995175727046881), "Incredible", "incredible"),
            (FaceFeatures(smile: 0.00534185412664101, eyeOpenness: 0.030796587467193604, neutrality: 0.994658145873359), "Kombucha", "kombucha"),
            (FaceFeatures(smile: 0.012820625863026791, eyeOpenness: 0.030953288078308105, neutrality: 0.9871793741369732), "Mewing", "mewing")
        ]

        var similarities: [(name: String, asset: String, similarity: Double)] = []

        for (targetFeatures, name, asset) in targets {
            func featureSimilarity(_ v: Double, _ t: Double) -> Double {
                if v == 0 && t == 0 { return 1 }
                if v == 0 || t == 0 { return 0 }
                return 1 - abs(v - t) / max(v, t)
            }
            
            let smileSim = featureSimilarity(features.smile, targetFeatures.smile)
            let eyeSim = featureSimilarity(features.eyeOpenness, targetFeatures.eyeOpenness)
            let neutralitySim = featureSimilarity(features.neutrality, targetFeatures.neutrality)
            
            let totalSimilarity = (smileSim + eyeSim + neutralitySim) / 3 * 100
            similarities.append((name, asset, totalSimilarity))
        }

        // Sort descending and take top 3
        let topMatches = similarities.sorted { $0.similarity > $1.similarity }.prefix(3)

        for match in topMatches {
            memes.append(MemeOption(name: match.name, assetName: match.asset))
        }




        return Array(memes.prefix(3))
    }
    
    
    
}
