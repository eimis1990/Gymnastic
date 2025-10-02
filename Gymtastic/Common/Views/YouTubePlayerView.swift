//
//  YouTubePlayerView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI
import WebKit

/// SwiftUI wrapper for WKWebView to play embedded YouTube videos
struct YouTubePlayerView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let videoID = extractVideoID(from: url) else { return }
        
        // Embedded YouTube player HTML with responsive iframe
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; }
                body { background-color: #000; }
                .video-container {
                    position: relative;
                    width: 100%;
                    padding-bottom: 56.25%; /* 16:9 aspect ratio */
                    height: 0;
                    overflow: hidden;
                }
                .video-container iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: 0;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe src="https://www.youtube.com/embed/\(videoID)?playsinline=1&autoplay=0&rel=0&modestbranding=1"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen>
                </iframe>
            </div>
        </body>
        </html>
        """
        
        uiView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    private func extractVideoID(from url: URL) -> String? {
        let urlString = url.absoluteString
        
        // Handle different YouTube URL formats
        if urlString.contains("youtube.com/watch?v=") {
            return URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "v" })?
                .value
        } else if urlString.contains("youtu.be/") {
            return url.lastPathComponent
        } else if urlString.contains("youtube.com/embed/") {
            return url.lastPathComponent
        }
        
        return nil
    }
}

// MARK: - Bottom Sheet Wrapper

struct YouTubeBottomSheet: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            // Video player
            YouTubePlayerView(url: url)
                .frame(height: 220) // 16:9 aspect ratio for ~360 width
                .cornerRadius(12)
                .padding(.horizontal, 16)
            
            // Close button
            Button(action: { dismiss() }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(Color.appBackground)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
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
                YouTubeBottomSheet(url: sampleURL)
            }
        }
    }
    
    return PreviewWrapper()
}

