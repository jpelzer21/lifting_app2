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
            .font(.title)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            
            // Back Button
            Button("Back") {
                selectedWorkoutTitle = "Back Day"
                selectedExercises = WorkoutTemplates.templates["Back Day"] ?? []
                showWorkoutView.toggle()
            }
            .font(.title)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            
            // Legs Button
            Button("Legs") {
                selectedWorkoutTitle = "Leg Day"
                selectedExercises = WorkoutTemplates.templates["Leg Day"] ?? []
                showWorkoutView.toggle()
            }
            .font(.title)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            
            // Custom Button
            Button("Custom") {
                selectedWorkoutTitle = "Custom Workout"
                selectedExercises = WorkoutTemplates.templates["Custom Day"] ?? []
                showWorkoutView.toggle()
            }
            .font(.title)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            
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
            .font(.title)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
        .navigationTitle("Home")
        .fullScreenCover(isPresented: $showWorkoutView) {
            WorkoutView(workoutTitle: $selectedWorkoutTitle, exercises: $selectedExercises) // Pass workout title
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

