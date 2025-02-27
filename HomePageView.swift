import SwiftUI
import FirebaseFirestore

struct HomePageView: View {
    @State private var showWorkoutView = false
    @State private var selectedExercises: [Exercise] = []
    @State private var selectedWorkoutTitle: String = "Empty Workout"
    @State private var templateNames: [String] = []
    @State private var isLoading = false
    
    
    var body: some View {
        VStack {
            
            if isLoading {
                ProgressView("Loading templates...")
                    .padding()
            } else {
                VStack {
                    Spacer()
                    ForEach(templateNames, id: \.self) { template in
                        Button(template) {
                            selectedWorkoutTitle = template
                            fetchTemplate(name: selectedWorkoutTitle) { exercises in
                                selectedExercises = exercises
                                showWorkoutView.toggle()
                            }
                        }
                        .homeButtonStyle()
                    }
                    
                    // Custom Button
                    Button("New Template") {
                        selectedWorkoutTitle = "Custom Workout"
                        fetchTemplate(name: selectedWorkoutTitle) { exercises in
                            selectedExercises = exercises
                            showWorkoutView.toggle()
                        }
                    }
                    .homeButtonStyle()
                    
                    //test button
//                    Button("test") {
//                    }
//                    .homeButtonStyle()
                    Spacer()
                }
                
                
            }
        }
        .onAppear {
            fetchTemplateNames()
        }
        .navigationTitle("Home")
        .fullScreenCover(isPresented: $showWorkoutView) {
            WorkoutView(workoutTitle: $selectedWorkoutTitle, exercises: $selectedExercises) // Pass workout title
        }
    }
    
    private func fetchTemplateNames() {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("templates").getDocuments { snapshot, error in
                print("before loading turned off\(isLoading)")
                isLoading = false
                print("after loading turned off\(isLoading)")
                if let error = error {
                    print("Error fetching templates: \(error.localizedDescription)")
                    return
                }
                if let snapshot = snapshot {
                    templateNames = snapshot.documents.map { $0.documentID.replacingOccurrences(of: "_", with: " ").capitalized }
                }
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

