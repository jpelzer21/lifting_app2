import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct WorkoutView: View {
//    @State private var workoutTitle: String = "Workout Title"
    @Binding var workoutTitle: String
    @Binding var exercises: [Exercise]
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var isEditingTitle: Bool = false
    

    private let db = Firestore.firestore()
    
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack (alignment: .center){
                    if isEditingTitle {
                        TextField("Enter Title:", text: $workoutTitle, onCommit: {
                            isEditingTitle = false
                        })
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(workoutTitle)
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding()
                            .onTapGesture {
                                isEditingTitle = true
                            }
                    }
                    
                    VStack {
                        ForEach($exercises, id: \.id) { $exercise in
                            ExerciseView(exercise: $exercise, deleteAction: {
                                if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
                                    exercises.remove(at: index)
                                }
                            })
                        }
                        .listRowBackground(Color(UIColor.systemBackground))
                        .listRowSeparator(.hidden)
                        
                        HStack {
                            Spacer()
                            Button("Add Exercise") {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                exercises.append(Exercise(name: "New Exercise", sets: [
                                    ExerciseSet(number: 1, weight: 0, reps: 0)
                                ]))
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle)
                            .tint(.blue)
                            .saturation(0.9)
                            .padding()
                            Button("Save Template") {
                                saveWorkoutAsTemplate()
                            }
                            Spacer()
                        }
                        .listRowBackground(Color(UIColor.systemBackground))
                        .listRowSeparator(.hidden)
                    }
                    .edgesIgnoringSafeArea(.all)
                    .listStyle(GroupedListStyle())
                    
                    
                    
                    
                }
                .onAppear {
                    loadWorkoutTemplate()
                }
            }
            .onTapGesture {// Dismiss the keyboard when tapping anywhere on the screen
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .toolbarBackgroundVisibility(.hidden)
            .navigationBarItems(trailing: Button("Finish Workout") {
                showingAlert = true
            }.alert(isPresented:$showingAlert) {
                Alert(
                    title: Text("You have completed \(completedSets()) exercises"),
                    primaryButton: .default(Text("Finish")) {
                        print("Workout Finished")
                        saveWorkoutAsTemplate()
                        saveExercises()
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("Stay"))
                )
            }.buttonStyle(.borderedProminent).tint(.green).saturation(0.85))
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        print("workout cancelled")
                    }) {
                        Label("Back", systemImage: "arrow.left")
                            .foregroundStyle(.red)
                    }
                }
            }
        }.padding()
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func completedSets() -> Int {
        var result = 0
        for exercise in exercises {
            var allSetsComplete = true
            for set in exercise.sets {
                if !set.isCompleted {
                    allSetsComplete = false
                }
            }
            if allSetsComplete {
                result += 1
            } else if exercise.allSetsCompleted {
                result += 1
            }
        }
        return result
    }
    
    
    private func saveExercises() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        for exercise in exercises {
            // Define the document reference for the exercise
            let exerciseRef = db.collection("users").document(userID).collection("exercises").document(exercise.name.lowercased().replacingOccurrences(of: " ", with: "_"))
                        
                        // Check if the exercise document exists
                        exerciseRef.getDocument { (document, error) in
                if let error = error {
                    print("Error checking exercise document: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists {
                    // If document exists, we don't need to add the name field
                    print("\(exercise.name) already exists in the database.")
                }
                let exerciseData: [String: Any] = [
                    "name": exercise.name
                ]
                
                exerciseRef.setData(exerciseData) { error in
                    if let error = error {
                        print("Error adding name for \(exercise.name): \(error.localizedDescription)")
                    } else {
                        print("Name added for \(exercise.name)!")
                    }
                }
                
            }
            
            // Add the sets data as before
            for set in exercise.sets {
                if set.isCompleted {
                    let newSetRef = exerciseRef.collection("sets").document() // Auto-generate a set ID
                    
                    let setData: [String: Any] = [
                        "date": Timestamp(date: Date()),
                        "setNum": set.number,
                        "weight": set.weight,
                        "reps": set.reps
                    ]
                    
                    newSetRef.setData(setData) { error in
                        if let error = error {
                            print("Error writing \(exercise.name) set: \(error.localizedDescription)")
                        } else {
                            print("Set added for \(exercise.name): \(setData)")
                        }
                    }
                }
            }
        }
    }
    
    private func saveWorkout() {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }

        let workoutRef = db.collection("users").document(user.uid).collection("workouts")
            .document(workoutTitle.lowercased().replacingOccurrences(of: " ", with: "_"))

        let workoutData: [String: Any] = [
            "title": workoutTitle,
            "timestamp": Timestamp(date: Date())
//            "weight": userWeight // User's weight at the time of the workout
        ]

        workoutRef.setData(workoutData) { error in
            if let error = error {
                print("Error saving workout: \(error.localizedDescription)")
            } else {
                print("Workout saved successfully!")
            }
        }
    }
    
    private func saveWorkoutAsTemplate() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in")
            return
        }
        let workoutRef = db.collection("users").document(userID)
            .collection("templates").document(workoutTitle.lowercased().replacingOccurrences(of: " ", with: "_"))
        var exercisesData: [[String: Any]] = []
        
        for exercise in exercises {
            var setsData: [[String: Any]] = []
            for set in exercise.sets {
                setsData.append([
                    "setNum": set.number,
                    "weight": set.weight,
                    "reps": set.reps
                ])
            }
            let exerciseData: [String: Any] = [
                "name": exercise.name,
                "sets": setsData
            ]
            exercisesData.append(exerciseData)
        }
        workoutRef.setData(["exercises": exercisesData]) { error in
            if let error = error {
                print("Error saving template: \(error.localizedDescription)")
            } else {
                print("Workout template saved successfully!")
            }
        }
    }
    
    private func loadWorkoutTemplate() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in")
            return
        }
        let workoutRef = db.collection("users").document(userID)
            .collection("templates").document(workoutTitle.replacingOccurrences(of: "_", with: " ").capitalized(with: .autoupdatingCurrent))
        
        workoutRef.getDocument { (document, error) in
            if let error = error {
                print("Error loading template: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists, let data = document.data(),
               let exercisesData = data["exercises"] as? [[String: Any]] {
                
                exercises = exercisesData.compactMap { exerciseDict in
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
            }
        }
    }
    
    
    
}

struct ExerciseView: View {
    @Binding var exercise: Exercise
    @State private var buttonPress = false
    @State private var showingAlert = false
    var deleteAction: () -> Void
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    
    private let doubleFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    var body: some View {
        
        
        VStack(alignment: .leading) {
            HStack {
                Button {
                } label: {
                    Text("...")
                }
                TextField("Exercise Name", text: $exercise.name)
                    .customTextFieldStyle()
                    .fontWeight(.medium)
                Button {
                    showingAlert = true
                    print("workout deleted")
                } label: {
                    Text("Delete")
                }.alert(isPresented:$showingAlert) {
                    Alert(
                        title: Text("Delete \(exercise.name)?"),
                        primaryButton: .destructive(Text("Delete")) {
                            print("\(exercise.name) deleted")
                            withAnimation {
                                deleteAction()
                            }
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
            }
            HStack{
                Text("set").frame(width: 75).multilineTextAlignment(.center)
                    .frame(width: 50)
                Spacer()
                Text("weight").frame(width: 75).multilineTextAlignment(.center)
                    .frame(width: 75)
                Spacer()
                Text("reps").frame(width: 75).multilineTextAlignment(.center)
                    .frame(width: 75)
                Spacer()
                ZStack{
                    Rectangle()
                        .fill(exercise.allSetsCompleted ? Color.green : Color.gray)
                        .frame(width: 25, height: 25)
                        .opacity(exercise.allSetsCompleted ? 0.8 : 0.3)
                        .cornerRadius(8)
                    Button {
                        generator.impactOccurred()
                        exercise.allSetsCompleted.toggle()
                        exercise.sets = exercise.sets.map { set in
                            var updatedSet = set
                            updatedSet.isCompleted = exercise.allSetsCompleted
                            return updatedSet
                        }
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Image(systemName: "checkmark").aspectRatio(contentMode: .fill).foregroundStyle(.black)
                    }
                }
            }
            ForEach($exercise.sets) { $set in
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill((set.isCompleted || exercise.allSetsCompleted) ? Color.green : Color(UIColor.systemBackground))
                        .opacity((set.isCompleted || exercise.allSetsCompleted) ? 0.3 : 1)
                        .saturation((set.isCompleted || exercise.allSetsCompleted) ? 0.6 : 1)
                    
                    HStack {
                    
                        Text("\(set.number)")
                            .frame(width: 50)
                        Spacer()
                        TextField("Weight", value: $set.weight, formatter: NumberFormatter())
                            .customTextFieldStyle()
                            .keyboardType(.decimalPad)
                            .frame(width: 75)
                        Spacer()
                        TextField("Reps", value: $set.reps, formatter: NumberFormatter())
                            .customTextFieldStyle()
                            .keyboardType(.decimalPad)
                            .frame(width: 75)
                        Spacer()
                        ZStack{
                            Rectangle()
                                .fill((set.isCompleted || exercise.allSetsCompleted) ? Color.green : Color.gray)
                                .frame(width: 25, height: 25)
                                .opacity((set.isCompleted || exercise.allSetsCompleted) ? 0.8 : 0.3)
                                .cornerRadius(8)
                            Button {
                                generator.impactOccurred()
                                set.isCompleted.toggle()
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            } label: {
                                Image(systemName: "checkmark").aspectRatio(contentMode: .fill).foregroundStyle(.black)
                            }
                        }
                    }
                }
                
                
            }
            
            HStack {
                Spacer()
                Button("Add Set") {
                    generator.impactOccurred()
                    exercise.sets.append(ExerciseSet(
                        number: exercise.sets.count + 1,
                        weight: exercise.sets[exercise.sets.count-1].weight,
                        reps: exercise.sets[exercise.sets.count-1].reps
                    ))
                }
                .customButtonStyle()
                .tint(.green)
                
                Button("Remove Set") {
                    if !exercise.sets.isEmpty {
                        generator.impactOccurred()
                        exercise.sets.removeLast()
                    }
                }
                .customButtonStyle()
                .tint(.red)
                .disabled(exercise.sets.isEmpty)
                Spacer()
            }
        }
        .padding()
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var sets: [ExerciseSet] = [ExerciseSet(number: 1, weight: 0, reps: 0)]
    var allSetsCompleted: Bool = false
}


struct ExerciseSet: Identifiable {
    let id = UUID()
    var number: Int
    var weight: Double
    var reps: Int
    var date: Date = Date()
    var isCompleted: Bool = false
}


extension View {
    func customTextFieldStyle() -> some View {
        self.modifier(CustomTextFieldStyle())
    }
}
extension View {
    func customButtonStyle() -> some View {
        self.modifier(CustomButtonStyle())
    }
}

//struct WorkoutView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutView(workoutTitle: .constant(""), exercises: .constant([]))
//    }
//}

