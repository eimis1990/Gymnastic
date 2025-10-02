//
//  YouTubePlayerView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI
import SafariServices

/// SwiftUI wrapper for SFSafariViewController to play YouTube videos
struct YouTubePlayerView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        configuration.barCollapsingEnabled = true
        
        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.preferredControlTintColor = .systemYellow
        controller.dismissButtonStyle = .done
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Convenience View Modifier

extension View {
    /// Presents a YouTube video in an in-app Safari view
    func youTubePlayer(url: URL?, isPresented: Binding<Bool>) -> some View {
        sheet(isPresented: isPresented) {
            if let url = url {
                YouTubePlayerView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var showPlayer = false
        let sampleURL = URL(string: "https://www.youtube.com/watch?v=dZgVxmf6jkA")!
        
        var body: some View {
            VStack {
                Button("Play YouTube Video") {
                    showPlayer = true
                }
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $showPlayer) {
                YouTubePlayerView(url: sampleURL)
            }
        }
    }
    
    return PreviewWrapper()
}

