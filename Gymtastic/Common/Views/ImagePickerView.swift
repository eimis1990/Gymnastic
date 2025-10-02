//
//  ImagePickerView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI
import PhotosUI

/// SwiftUI wrapper for PHPickerViewController
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    let sourceType: SourceType
    
    enum SourceType {
        case camera
        case photoLibrary
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        switch sourceType {
        case .camera:
            return makeCameraController(context: context)
        case .photoLibrary:
            return makePhotoPickerController(context: context)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
    
    // MARK: - Camera Controller
    
    private func makeCameraController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    // MARK: - Photo Picker Controller
    
    private func makePhotoPickerController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    // MARK: - Coordinator
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        // MARK: - UIImagePickerControllerDelegate
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
        
        // MARK: - PHPickerViewControllerDelegate
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.selectedImage = image
                    }
                }
            }
        }
    }
}

// MARK: - Preview Helper

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedImage: UIImage?
        @State private var showPicker = false
        
        var body: some View {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
                
                Button("Select Photo") {
                    showPicker = true
                }
                .sheet(isPresented: $showPicker) {
                    ImagePickerView(
                        selectedImage: $selectedImage,
                        sourceType: .photoLibrary
                    )
                }
            }
        }
    }
    
    return PreviewWrapper()
}

