import SwiftUI
import PhotosUI

struct HomepageView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Meme Maker")
                .font(.largeTitle)
                .bold()
            
          
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 250, height: 250)
                    .cornerRadius(12)
                    .overlay(Text("No Image Selected"))
            }
            
          
            PhotosPicker("Upload Photo", selection: $selectedItem, matching: .images)
                .buttonStyle(.borderedProminent)
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }
        }
        .padding()
    }
}

#Preview {
    HomepageView()
}

