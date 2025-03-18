import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HomePageView: View {
    @State private var showWorkoutView = false
    @State private var selectedExercises: [Exercise] = []
    @State private var selectedWorkoutTitle: String = "Empty Workout"
    @State private var templates: [WorkoutTemplate] = []
    @State private var isLoading = false
    @State private var showProfileView = false
    @State private var userID: String? = Auth.auth().currentUser?.uid
    @State private var showDeleteButton = false

    var body: some View {
        ScrollView {
            VStack {
                Text("Quick Workout:")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20).padding(.top, 30)
                Button {
                    selectedWorkoutTitle = "New Workout"
                    selectedExercises = []
                    showWorkoutView.toggle()
                } label: {
                    Text("Start New Workout")
                        .frame(width: UIScreen.main.bounds.width-60, height: 25, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .homeButtonStyle()
                
                HStack {
                    Text("My Templates:")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    Spacer()
                    if !templates.isEmpty {
                        Button {
                            showDeleteButton.toggle()
                        } label: {
                            Image(systemName: showDeleteButton ? "ellipsis.rectangle.fill" :"ellipsis")
                                .imageScale(.large)
                                .frame(width: 10, height: 10)
                                .foregroundColor(.pink)
                                .padding()
                                .shadow(radius: 5)
                        }
                    }
                    Button(action: {
                        selectedWorkoutTitle = "New Template"
                        selectedExercises = []
                        showWorkoutView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .frame(width: 10, height: 10)
                            .foregroundColor(.pink)
                            .padding()
                            .shadow(radius: 5)
                    }
                }.padding(.trailing, 20)
                
                if !isLoading {
                    
                    if templates.count > 0 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10){
                                ForEach(templates) { template in
                                    TemplateCard(
                                        templateName: template.name,
                                        exercises: template.exercises,
                                        showDeleteButton: showDeleteButton,
                                        onTap: {
                                            selectedWorkoutTitle = template.name
                                            selectedExercises = template.exercises
                                            showWorkoutView.toggle()
                                        },
                                        onDelete: {
                                            deleteTemplate(templateID: template.id) // Pass delete action
                                        }
                                    )
                                }
                            }.padding(.leading, 20).padding(.vertical, 10)
                        }
                    } else {
                        VStack {
                            Spacer()
                            Image(systemName: "dumbbell.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)
                            
                            Text("No Templates Yet!")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Add a Template by pressing the + button")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                    }
                    
                } else {
                    ProgressView("Loading templates...")
                        .padding()
                }
                
                Text("Example Templates:")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack(spacing: 10){
                        ForEach(ExampleTemplates.templates) { template in
                            TemplateCard(
                                templateName: template.name,
                                exercises: template.exercises,
                                showDeleteButton: false,
                                onTap: {
                                    selectedWorkoutTitle = template.name
                                    selectedExercises = template.exercises
                                    showWorkoutView.toggle()
                                },
                                onDelete: {
                                    deleteTemplate(templateID: template.id) // Pass delete action
                                }
                            )
                            .transition(.opacity) // Fade animation
//                            .animation(.easeInOut(duration: 0.3), value: template)
                        }
                    }.padding(.leading, 20).padding(.vertical, 10)
                }
                
                Spacer()
            }
            
        }
        .refreshable {
            fetchTemplates()
        }
        .onAppear {
            fetchTemplates()
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
            WorkoutView(workoutTitle: $selectedWorkoutTitle, exercises: $selectedExercises)
        }
        .fullScreenCover(isPresented: $showProfileView) {
            ProfileView()
        }
    }

    // Fetch all templates including exercises
    private func fetchTemplates() {
        guard let userID = userID else { return }
        isLoading = true
        let db = Firestore.firestore()

        db.collection("users").document(userID).collection("templates")
            .order(by: "lastEdited", descending: true)
            .getDocuments { snapshot, error in
                isLoading = false
                if let error = error {
                    print("❌ Error fetching templates: \(error.localizedDescription)")
                    templates = []
                    return
                }

                templates = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    let name = doc.documentID.replacingOccurrences(of: "_", with: " ").capitalized
                    let exercises = (data["exercises"] as? [[String: Any]])?.compactMap { exerciseDict -> Exercise? in
                        guard let name = exerciseDict["name"] as? String else { return nil }
                        
                        let sets = (exerciseDict["sets"] as? [[String: Any]])?.compactMap { setDict -> ExerciseSet? in
                            let setNum = setDict["setNum"] as? Int ?? 0
                            let weight = setDict["weight"] as? Double ?? 0.0
                            let reps = setDict["reps"] as? Int ?? 0
                            return ExerciseSet(number: setNum, weight: weight, reps: reps)
                        } ?? []
                        
                        return Exercise(name: name, sets: sets)
                    } ?? []
                    return WorkoutTemplate(id: doc.documentID, name: name, exercises: exercises)
                } ?? []
            }
    }
    
    private func deleteTemplate(templateID: String) {
        guard let userID = userID else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userID).collection("templates").document(templateID).delete { error in
            if let error = error {
                print("❌ Error deleting template: \(error.localizedDescription)")
            } else {
                // Remove the template from the local state
                templates.removeAll { $0.id == templateID }
            }
        }
    }
    
}

struct WorkoutTemplate: Identifiable {
    let id: String // Same as Firestore document ID
    let name: String
    let exercises: [Exercise] // Store only exercise names for now
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
