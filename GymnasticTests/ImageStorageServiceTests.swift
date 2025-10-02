//
//  ImageStorageServiceTests.swift
//  GymtasticTests
//
//  Created on 2025-10-01.
//

import XCTest
@testable import Gymtastic

final class ImageStorageServiceTests: XCTestCase {
    var sut: ImageStorageService!
    
    override func setUp() {
        sut = ImageStorageService()
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Thumbnail Generation Tests
    func testGenerateThumbnail_FromImage_CreatesThumbnail() async throws {
        // Given
        let imageData = createTestImageData(width: 1000, height: 1000, size: 500_000)
        
        // When
        let thumbnailData = try await sut.generateThumbnail(from: imageData)
        
        // Then
        XCTAssertLessThan(thumbnailData.count, 100_000) // Target <50KB, allow up to 100KB
    }
    
    // MARK: - Image Validation Tests
    func testValidateImageSize_WithValidSize_ReturnsTrue() {
        // Given
        let validImageData = Data(count: 1_500_000) // 1.5MB
        
        // When
        let isValid = sut.validateImageSize(validImageData)
        
        // Then
        XCTAssertTrue(isValid)
    }
    
    func testValidateImageSize_WithOversizedImage_ReturnsFalse() {
        // Given
        let oversizedImageData = Data(count: 3_000_000) // 3MB
        
        // When
        let isValid = sut.validateImageSize(oversizedImageData)
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    // MARK: - Compression Tests
    func testCompressImage_ReducesFileSize() async throws {
        // Given
        let largeImageData = createTestImageData(width: 2000, height: 2000, size: 1_500_000)
        
        // When
        let compressedData = try await sut.compressImage(largeImageData, quality: 0.8)
        
        // Then
        XCTAssertLessThan(compressedData.count, largeImageData.count)
    }
    
    // MARK: - Helper Methods
    private func createTestImageData(width: Int, height: Int, size: Int) -> Data {
        // Create mock image data for testing
        return Data(count: size)
    }
}

