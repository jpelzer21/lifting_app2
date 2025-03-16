//
//  ExerciseListView.swift
//  lift
//
//  Created by Josh Pelzer on 2/24/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ExerciseListView: View {
    @State private var exercises: [String] = []
    @State private var isLoading = true
        
    var body: some View {
        NavigationView {
            if isLoading {
                VStack {
                    ProgressView("Loading...")
                        .padding()
                }
            } else if exercises.isEmpty{
                VStack(alignment: .center) {
                    Image(systemName: "dumbbell.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)

                    Text("No exercises yet!")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Add an exercise by making a template!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 100)
            } else {
                ScrollView {
                    VStack {
                        ForEach(exercises, id: \.self) { exercise in
                            NavigationLink(destination: GraphView(exerciseName: exercise)) {
                                ExerciseCard(exerciseName: exercise)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }.navigationTitle("Exercises")
                }
            }
        }
        .onAppear(perform: fetchExercises)
    }
    
    func fetchExercises() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("exercises").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching exercises: \(error.localizedDescription)")
                    self.exercises = [] // Clear in case of failure
                } else {
                    self.exercises = snapshot?.documents.map { $0.documentID } ?? []
                }
                self.isLoading = false
            }
        }
    }
}

