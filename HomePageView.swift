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

