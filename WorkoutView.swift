import SwiftUI

struct WorkoutView: View {
//    @State private var workoutTitle: String = "Workout Title"
    @Binding var workoutTitle: String
    @Binding var exercises: [Exercise]
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack (alignment: .center){
                    TextField("Enter Workout Title", text: $workoutTitle)
                        .customTextFieldStyle()
                        .font(.largeTitle)
                    
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
                    .padding()
                    
                }
            }
            .toolbarBackgroundVisibility(.hidden)
            .navigationBarItems(trailing: Button("Finish Workout") {
                finishWorkout()
                presentationMode.wrappedValue.dismiss()
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
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        print("Deleting exercise at index:", offsets)
        exercises.remove(atOffsets: offsets)
    }
    
    private func finishWorkout() {
        print("Workout Title: \(workoutTitle)")
        for exercise in exercises {
            print("Exercise: \(exercise.name)")
            for set in exercise.sets {
                print("Set \(set.number): Weight: \(set.weight), Reps: \(set.reps)")
            }
            print(Date().formatted(date: .numeric, time: .omitted))
        }
    }
}

struct ExerciseView: View {
    @Binding var exercise: Exercise
    
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
                        .fill(Color.gray)
                        .frame(width: 25, height: 25)
                        .opacity(0.3)
                        .cornerRadius(8)
                    Button {} label: {
                        Image(systemName: "checkmark").aspectRatio(contentMode: .fill).foregroundStyle(.black)
                    }
                }
            }
            ForEach($exercise.sets) { $set in
                VStack{
                    
                    
                    HStack {
                        Text("\(set.number)")
                            .frame(width: 50)
                        Spacer()
                        TextField("Weight", value: $set.weight, formatter: NumberFormatter())
                            .customTextFieldStyle()
                            .frame(width: 75)
                        Spacer()
                        TextField("Reps", value: $set.reps, formatter: NumberFormatter())
                            .customTextFieldStyle()
                            .frame(width: 75)
                        Spacer()
                        ZStack{
                            Rectangle()
                                .fill(set.isCompleted ? Color.green : Color.gray)
                                .frame(width: 25, height: 25)
                                .opacity(set.isCompleted ? 0.8 : 0.3)
                                .cornerRadius(8)
                            Button {
                                set.isCompleted.toggle()
                                print(set.isCompleted)
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
}

struct ExerciseSet: Identifiable {
    let id = UUID()
    var number: Int
    var weight: Double
    var reps: Int
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

