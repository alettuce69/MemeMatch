import SwiftUI
import PhotosUI

struct HomepageView: View {
    
    @State private var selectedImage: UIImage? = nil
    @State private var croppedFace: UIImage? = nil
    @State private var faceBox: CGRect? = nil
    @State private var memes: [MemeOption] = []
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var navigateToMemes: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.orange, .blue]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack(spacing: 18) {
                    Text("Meme Matcher")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 18)
                    
                    Group {
                        if let img = selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                                .cornerRadius(14)
                                .shadow(radius: 6)
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.18))
                                .frame(height: 250)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 44))
                                            .foregroundColor(.white.opacity(0.9))
                                        Text("No image selected")
                                            .foregroundColor(.white.opacity(0.9))
                                            .font(.headline)
                                    }
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Text(selectedImage == nil ? "Pick a Photo" : "Change Photo")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.18))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .onChange(of: selectedItem, initial: false) { oldItem, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    await MainActor.run {
                                        selectedImage = uiImage
                                        croppedFace = nil
                                        faceBox = nil
                                        memes = []
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            analyzeAndGenerateMemes()
                        }) {
                            Text("Generate Memes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedImage == nil ? Color.gray.opacity(0.45) : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(selectedImage == nil)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
            }
            .navigationDestination(isPresented: $navigateToMemes) {
                if let face = croppedFace, memes.count > 0 {
                    MemeOverlayView(userFace: face, memes: memes)
                } else {
                    VStack {
                        Text("Could not generate memes")
                        Button("Back") { navigateToMemes = false }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    private func analyzeAndGenerateMemes() {
        guard let image = selectedImage else {
            return
        }
        
        FaceAnalyzer.analyzeFace(from: image) { features, faceCrop, box in
            DispatchQueue.main.async {
                if let f = features {
                    self.memes = MemeClassifier.classify(features: f)
                    self.croppedFace = faceCrop
                    self.faceBox = box
                    self.navigateToMemes = true
                } else {
                    self.croppedFace = nil
                    self.memes = []
                    self.faceBox = nil
                    self.navigateToMemes = false
                }
            }
        }
    }
}

#Preview {
    HomepageView()
}

