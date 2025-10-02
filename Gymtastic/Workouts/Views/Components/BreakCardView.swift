//
//  BreakCardView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI

struct BreakCardView: View {
    let breakItem: Break
    
    var body: some View {
        HStack(spacing: 12) {
            // Drag Handle
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.title3)
            
            // Break Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "timer")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            
            // Break Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Break")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(breakItem.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Position Badge
            Text("#\(breakItem.position + 1)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .padding(12)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        BreakCardView(
            breakItem: Break(durationSeconds: 60, position: 1)
        )
        
        BreakCardView(
            breakItem: Break(durationSeconds: 120, position: 3)
        )
    }
    .padding()
}

