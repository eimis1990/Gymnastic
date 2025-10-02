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
            // Break Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.info.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "timer")
                    .foregroundColor(.info)
                    .font(.title3)
            }
            
            // Break Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Break")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(breakItem.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Position Badge
            Text("#\(breakItem.position + 1)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.info)
                .cornerRadius(8)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.info.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.shadowStandard, radius: 4, x: 0, y: 2)
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

