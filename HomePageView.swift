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
                selectedExercises = WorkoutTemplates.templates["Chest Day"] ?? []
                showWorkoutView.toggle()
            }
            .homeButtonStyle()
            
            // Back Button
            Button("Back") {
                selectedWorkoutTitle = "Back Day"
                selectedExercises = WorkoutTemplates.templates["Back Day"] ?? []
                showWorkoutView.toggle()
            }
            .homeButtonStyle()
            
            // Legs Button
            Button("Legs") {
                selectedWorkoutTitle = "Leg Day"
                selectedExercises = WorkoutTemplates.templates["Leg Day"] ?? []
                showWorkoutView.toggle()
            }
            .homeButtonStyle()
            
            // Custom Button
            Button("Custom") {
                selectedWorkoutTitle = "Custom Workout"
                selectedExercises = WorkoutTemplates.templates["Custom Day"] ?? []
                showWorkoutView.toggle()
            }
            .homeButtonStyle()
            
            //test button
            Button("test") {
                let db = Firestore.firestore()
                    let setsRef = db.collection("exercises").document("Bench Press").collection("sets")

                    setsRef.getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching sets: \(error.localizedDescription)")
                            return
                        }

                        guard let documents = snapshot?.documents else {
                            print("No sets found for bench press.")
                            return
                        }

                        for document in documents {
                            let data = document.data()
                            let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                            let reps = (data["reps"] as? Int) ?? 0
                            let weight = (data["weight"] as? Double) ?? 0.0
                            
                            print("Date: \(date), Reps: \(reps), Weight: \(weight) lbs")
                        }
                    }
            }
            .homeButtonStyle()
        }
        .navigationTitle("Home")
        .fullScreenCover(isPresented: $showWorkoutView) {
            WorkoutView(workoutTitle: $selectedWorkoutTitle, exercises: $selectedExercises) // Pass workout title
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

