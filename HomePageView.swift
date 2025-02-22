import SwiftUI

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
                // Get the Chest Day workout template from WorkoutTemplates
                if let chestDayExercises = WorkoutTemplates.templates["Chest Day"] {
                    for exercise in chestDayExercises {
                        print("Exercise: \(exercise.name)")
                        for set in exercise.sets {
                            print("Set \(set.number): \(set.reps) reps at \(set.weight) lbs")
                        }
                    }
                } else {
                    print("No Chest Day template found.")
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

