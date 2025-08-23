import SwiftUI
import PhotosUI
import Vision
import UIKit

struct HomepageView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        
        
        VStack(spacing: 30) {
            Text("Meme Match")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            if let image = selectedImage {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    .padding()
            } else {
                
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundColor(.gray)
                    .frame(width: 250, height: 250)
                    .overlay(
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    )
            }
            
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Pick a Photo")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            .onChange(of: selectedItem) { newItem in
                if let newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    HomepageView()
}
