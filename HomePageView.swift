import SwiftUI

struct HomePageView: View {
    @State private var showWorkoutView = false
//    @State private var workoutTitle = "" // Variable to store the workout title
    @State private var selectedWorkoutTitle: String = "Empty Workout"

    
    var body: some View {
        VStack {
            // Chest Button
            Button("Chest") {
                selectedWorkoutTitle = "Chest Workout"
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
                selectedWorkoutTitle = "Back Workout"
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
                selectedWorkoutTitle = "Legs Workout"
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
                showWorkoutView.toggle()
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
            WorkoutView(workoutTitle: $selectedWorkoutTitle) // Pass workout title
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

