//
//  HomepageView.swift
//  MemeMatch
//
//  Created by Gautham Dinakaran on 16/8/25.
//

import SwiftUI
import PhotosUI

struct HomepageView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false
    @State private var selecteditem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("MemeWatch")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .position(x: 180, y:40)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .cornerRadius(12)
                        .overlay(
                            Text("No Image Selected")
                                .foregroundColor(.gray)
                        )
                }
                
                Button(action: {
                    isPickerPresented.toggle()
                    PhotosPicker(selection: $selecteditem, matching: .images)
                }) {
                    Text("Upload Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
         
             
            }
        }
    }




#Preview {
    HomepageView()
}
