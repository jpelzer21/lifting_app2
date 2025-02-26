import SwiftUI
import FirebaseFirestore

struct HomePageView: View {
    @State private var showWorkoutView = false
    @State private var selectedExercises: [Exercise] = []
    @State private var selectedWorkoutTitle: String = "Empty Workout"
    
    
    var body: some View {
        VStack {
            // Chest Button
            Button("Chest") {
                selectedWorkoutTitle = "Chest Day"
                fetchTemplate(name: selectedWorkoutTitle) { exercises in
                    selectedExercises = exercises
                    showWorkoutView.toggle()
                }
//                selectedExercises = WorkoutTemplates.templates["Chest Day"] ?? []
//                showWorkoutView.toggle()
            }
            .homeButtonStyle()
            
            // Back Button
            Button("Back") {
                selectedWorkoutTitle = "Back Day"
                fetchTemplate(name: selectedWorkoutTitle) { exercises in
                    selectedExercises = exercises
                    showWorkoutView.toggle()
                }
//                selectedExercises = WorkoutTemplates.templates["Back Day"] ?? []
//                showWorkoutView.toggle()
            }
            .homeButtonStyle()
            
            // Legs Button
            Button("Legs") {
                selectedWorkoutTitle = "Leg Day"
                fetchTemplate(name: selectedWorkoutTitle) { exercises in
                    selectedExercises = exercises
                    showWorkoutView.toggle()
                }
//                selectedExercises = WorkoutTemplates.templates["Leg Day"] ?? []
//                showWorkoutView.toggle()
            }
            .homeButtonStyle()
            
            // Custom Button
            Button("Custom") {
                selectedWorkoutTitle = "Custom Workout"
                fetchTemplate(name: selectedWorkoutTitle) { exercises in
                    selectedExercises = exercises
                    showWorkoutView.toggle()
                }
//                selectedExercises = WorkoutTemplates.templates["Custom Day"] ?? []
//                showWorkoutView.toggle()
            }
            .homeButtonStyle()
            
            //test button
            Button("test") {
            }
            .homeButtonStyle()
        }
        .navigationTitle("Home")
        .fullScreenCover(isPresented: $showWorkoutView) {
            WorkoutView(workoutTitle: $selectedWorkoutTitle, exercises: $selectedExercises) // Pass workout title
        }
    }
    
    private func fetchTemplate(name: String, completion: @escaping ([Exercise]) -> Void) {
        let db = Firestore.firestore()
        let workoutRef = db.collection("templates").document(name.lowercased().replacingOccurrences(of: " ", with: "_"))

        workoutRef.getDocument { (document, error) in
                if let error = error {
                    print("Error loading template: \(error.localizedDescription)")
                    completion([]) // Return an empty array if there's an error
                    return
                }

                if let document = document, document.exists, let data = document.data(),
                   let exercisesData = data["exercises"] as? [[String: Any]] {
                    
                    // Parse the exercises data into [Exercise]
                    let exercises = exercisesData.compactMap { exerciseDict -> Exercise? in
                        guard let name = exerciseDict["name"] as? String,
                              let setsData = exerciseDict["sets"] as? [[String: Any]] else { return nil }
                        
                        let sets = setsData.compactMap { setDict -> ExerciseSet? in
                            guard let setNum = setDict["setNum"] as? Int,
                                  let weight = setDict["weight"] as? Double,
                                  let reps = setDict["reps"] as? Int else { return nil }
                            return ExerciseSet(number: setNum, weight: weight, reps: reps)
                        }

                        return Exercise(name: name, sets: sets)
                    }
                    
                    completion(exercises) // Return the fetched exercises
                } else {
                    completion([]) // Return an empty array if the document doesn't exist or data is invalid
                }
            }
    }
    
}


extension View {
    func homeButtonStyle() -> some View {
        self.modifier(HomeButtonStyle())
    }
}



struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

