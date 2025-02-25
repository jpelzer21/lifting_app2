//
//  ExerciseListView.swift
//  lift
//
//  Created by Josh Pelzer on 2/24/25.
//

import SwiftUI
import FirebaseFirestore

struct ExerciseListView: View {
    @State private var exercises: [String] = []
    @State private var isLoading = true
        
    var body: some View {
        NavigationView {
            List(exercises, id: \..self) { exercise in
                NavigationLink(destination: GraphView(exerciseName: exercise)) {
                    Text(exercise)
                }
            }
            .navigationTitle("Exercises")
            .onAppear(perform: fetchExercises)
        }
    }
    
    func fetchExercises() {
        let db = Firestore.firestore()
        db.collection("exercises").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching exercises: \(error.localizedDescription)")
                return
            }
            exercises = snapshot?.documents.compactMap { $0.documentID } ?? []
            isLoading = false
        }
    }
}

