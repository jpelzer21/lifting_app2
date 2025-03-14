import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HomePageView: View {
    @State private var showWorkoutView = false
    @State private var selectedExercises: [Exercise] = []
    @State private var selectedWorkoutTitle: String = "Empty Workout"
    @State private var templateNames: [String] = []
    @State private var isLoading = false
    @State private var showProfileView = false
    @State private var userID: String? = Auth.auth().currentUser?.uid
    
    
    var body: some View {
        VStack {
            
            if isLoading {
                ProgressView("Loading templates...")
                    .padding()
            } else {
                VStack {
                    Spacer()
                    Text("Templates:")
                        .font(.title2)
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
                    .padding(50)
                    Spacer()
                }
                
                
            }
        }
        .onAppear {
            fetchTemplateNames()
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showProfileView.toggle()
                }) {
                    Image(systemName: "person.circle")
                        .font(.title)
                        .foregroundColor(.pink)
                }
            }
        }
        .fullScreenCover(isPresented: $showWorkoutView) {
            WorkoutView(workoutTitle: $selectedWorkoutTitle, exercises: $selectedExercises) // Pass workout title
        }
        .fullScreenCover(isPresented: $showProfileView) {
            ProfileView()
        }
    }
    
    private func fetchTemplateNames() {
        guard let userID = userID else { return }
            isLoading = true
            let db = Firestore.firestore()
            db.collection("users").document(userID).collection("templates").getDocuments { snapshot, error in
                isLoading = false
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
        guard let userID = userID else { return }
            let db = Firestore.firestore()
            let templateRef = db.collection("users").document(userID).collection("templates").document(name.lowercased().replacingOccurrences(of: " ", with: "_"))

            templateRef.getDocument { (document, error) in
                if let error = error {
                    print("Error loading template: \(error.localizedDescription)")
                    completion([])
                    return
                }

                if let document = document, document.exists, let data = document.data(),
                   let exercisesData = data["exercises"] as? [[String: Any]] {
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
                    completion(exercises)
                } else {
                    completion([])
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

