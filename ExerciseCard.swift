//
//  ExerciseCard.swift
//  lift
//
//  Created by Josh Pelzer on 3/16/25.
//

import SwiftUI

struct ExerciseCard: View {
    let exerciseName: String

    var body: some View {
        HStack {
            Image(systemName: "dumbbell.fill")
                .foregroundColor(.gray)
                .font(.title2)
                .padding(10)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(10)
            
            Text(exerciseName.replacingOccurrences(of: "_", with: " ").capitalized(with: .autoupdatingCurrent))
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
