import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HistoryView: View {
    @State private var workouts: [(title: String, date: Date, exercises: [String])] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
                VStack {
                    if isLoading {
                        ProgressView("Loading workouts...")
                            .padding()
                    } else if workouts.isEmpty {
                        VStack {
                            Image(systemName: "list.bullet.rectangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                            
                            Text("No workout history found!")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 100)
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(workouts, id: \.title) { workout in
                                    WorkoutCard(workout: workout)
                                }
                            }
                            .padding()
                        }
                    }
                }
            .navigationTitle("Workout History")
            .onAppear(perform: fetchWorkoutHistory)
        }
    }
    
    private func fetchWorkoutHistory() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("workouts")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching workouts: \(error.localizedDescription)")
                        self.workouts = []
                    } else {
                        self.workouts = snapshot?.documents.compactMap { doc in
                            let title = doc["title"] as? String ?? "No Title"
                            let exercises = doc["exercises"] as? [String] ?? []
                            let timestamp = (doc["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                            return (title, timestamp, exercises)
                        } ?? []
                    }
                    self.isLoading = false
                }
            }
    }
}

struct WorkoutCard: View {
    @Environment(\.colorScheme) var colorScheme
    var workout: (title: String, date: Date, exercises: [String])
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(.pink)
                    .font(.title2)
                
                Text(workout.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(formatDate(workout.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(workout.exercises, id: \.self) { exercise in
                    HStack {
                        Text("• ")
                            .font(.headline)
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(.green)
                        Text(exercise)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .cornerRadius(12)
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
