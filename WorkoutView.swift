import SwiftUI
import FirebaseFirestore

struct WorkoutView: View {
//    @State private var workoutTitle: String = "Workout Title"
    @Binding var workoutTitle: String
    @Binding var exercises: [Exercise]
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    private let db = Firestore.firestore()
    
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack (alignment: .center){
                    Text(workoutTitle)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    VStack {
                        ForEach($exercises, id: \.id) { $exercise in
                            ExerciseView(exercise: $exercise)
                        }
                        .onDelete(perform: deleteExercise)
                    }
                    
                    Button("Add Exercise") {
                        exercises.append(Exercise(name: "New Exercise", sets: [
                            ExerciseSet(number: 1, weight: 0, reps: 0),
                            ExerciseSet(number: 2, weight: 0, reps: 0),
                            ExerciseSet(number: 3, weight: 0, reps: 0)
                        ]))
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    .tint(.blue)
                    .saturation(0.9)
                    .padding()
                    
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
                        finishWorkout()
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
    
    private func deleteExercise(at offsets: IndexSet) {
        print("Deleting exercise at index:", offsets)
        exercises.remove(atOffsets: offsets)
    }
    
    private func finishWorkout() {
        writeData()
    }
    
    private func writeData() {
        for exercise in exercises {
            // Define the document reference for the exercise
            let exerciseRef = db.collection("exercises").document(exercise.name.lowercased().replacingOccurrences(of: " ", with: "_"))
            
            // Check if the exercise document exists
            exerciseRef.getDocument { (document, error) in
                if let error = error {
                    print("Error checking exercise document: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists {
                    // If document exists, we don't need to add the name field
                    print("\(exercise.name) already exists in the database.")
                } else {
                    // If document doesn't exist, create it and add the name field
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
}

struct ExerciseView: View {
    @Binding var exercise: Exercise
    @State private var buttonPress = false
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Exercise Name", text: $exercise.name)
                .customTextFieldStyle()
                .fontWeight(.medium)
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
                        exercise.allSetsCompleted.toggle()
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
                                set.isCompleted.toggle()
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
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
                    exercise.sets.append(ExerciseSet(number: exercise.sets.count + 1, weight: 0, reps: 0))
                }
                .customButtonStyle()
                .tint(.green)
                
                Button("Remove Set") {
                    if !exercise.sets.isEmpty {
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

