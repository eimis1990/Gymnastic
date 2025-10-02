//
//  ImageStorageService.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import UIKit
import Foundation

/// Service for image processing and storage
final class ImageStorageService {
    private let thumbnailSize = CGSize(width: 200, height: 200)
    private let thumbnailQuality: CGFloat = 0.7
    private let fullImageQuality: CGFloat = 0.8
    
    // MARK: - Thumbnail Generation
    
    /// Generates a thumbnail from image data
    func generateThumbnail(from imageData: Data) async throws -> Data {
        guard let originalImage = UIImage(data: imageData) else {
            throw ImageStorageError.invalidImageData
        }
        
        let thumbnail = await resizeImage(originalImage, to: thumbnailSize)
        
        guard let thumbnailData = thumbnail.jpegData(compressionQuality: thumbnailQuality) else {
            throw ImageStorageError.compressionFailed
        }
        
        return thumbnailData
    }
    
    // MARK: - Image Validation
    
    /// Validates image size is within limits
    func validateImageSize(_ imageData: Data) -> Bool {
        return imageData.count <= 2_000_000 // 2MB
    }
    
    // MARK: - Image Compression
    
    /// Compresses an image with specified quality
    func compressImage(_ imageData: Data, quality: CGFloat) async throws -> Data {
        guard let image = UIImage(data: imageData) else {
            throw ImageStorageError.invalidImageData
        }
        
        guard let compressedData = image.jpegData(compressionQuality: quality) else {
            throw ImageStorageError.compressionFailed
        }
        
        return compressedData
    }
    
    // MARK: - Image Resizing
    
    private func resizeImage(_ image: UIImage, to targetSize: CGSize) async -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine the scale factor that maintains aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }
}

// MARK: - Error Types

enum ImageStorageError: LocalizedError {
    case invalidImageData
    case compressionFailed
    case resizingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Invalid image data"
        case .compressionFailed:
            return "Failed to compress image"
        case .resizingFailed:
            return "Failed to resize image"
        }
    }
}

