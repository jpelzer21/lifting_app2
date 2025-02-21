import SwiftUI

struct WorkoutView: View {
//    @State private var workoutTitle: String = "Workout Title"
    @State private var exercises: [Exercise] = []
    @Environment(\.presentationMode) var presentationMode
    @Binding var workoutTitle: String
    
   
    
    var body: some View {
        NavigationView {
            VStack (alignment: .center){
                TextField("Enter Workout Title", text: $workoutTitle)
                    .font(.largeTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack {
                    ForEach($exercises) { $exercise in
                        ExerciseView(exercise: $exercise)
                    }
                    .onDelete(perform: deleteExercise)
                }.disabled(false)
                
                Button("Add Exercise") {
                    exercises.append(Exercise(name: "New Exercise"))
                }
                .padding()
            }
//            .navigationTitle("Workout Tracker")
            .navigationBarItems(trailing: Button("Finish Workout") {
                finishWorkout()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
    
    private func finishWorkout() {
        print("Workout Title: \(workoutTitle)")
        for exercise in exercises {
            print("Exercise: \(exercise.name)")
            for set in exercise.sets {
                print("Set \(set.number): Weight: \(set.weight), Reps: \(set.reps)")
            }
        }
    }
}

struct ExerciseView: View {
    @Binding var exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Exercise Name", text: $exercise.name)
                .font(.headline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 5)
            HStack{
                Text("set").frame(width: 75).multilineTextAlignment(.center)
                Spacer()
                Text("weight").frame(width: 75).multilineTextAlignment(.center)
                Spacer()
                Text("reps").frame(width: 75).multilineTextAlignment(.center)
                Spacer()
                ZStack{
                    Rectangle()
                        .frame(width: 25, height: 25)
                        .backgroundStyle(.gray)
                        .opacity(0.3)
                        .cornerRadius(8)
                    Button{}label: {
                        Image(systemName: "checkmark").aspectRatio(contentMode: .fill).foregroundStyle(.black)
                    }
                }
            }
            ForEach($exercise.sets) { $set in
                VStack{
                    
                    
                    HStack {
                        Text("\(set.number)")
                        Spacer()
                        TextField("Weight", value: $set.weight, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(width: 75)
                            .multilineTextAlignment(.center)
                        Spacer()
                        TextField("Reps", value: $set.reps, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 75)
                            .multilineTextAlignment(.center)
                        Spacer()
                        ZStack{
                            Rectangle()
                                .frame(width: 25, height: 25)
                                .backgroundStyle(.gray)
                                .opacity(0.3)
                                .cornerRadius(8)
                            Button{}label: {
                                Image(systemName: "checkmark").aspectRatio(contentMode: .fill).foregroundStyle(.black)
                            }
                        }
                    }
                }
            }
            
            HStack {
                Button("Add Set") {
                    exercise.sets.append(ExerciseSet(number: exercise.sets.count + 1, weight: 0, reps: 0))
                }
                .padding(.top, 5)
                
                Button("Remove Set") {
                    if !exercise.sets.isEmpty {
                        exercise.sets.removeLast()
                    }
                }
                .padding(.top, 5)
                .disabled(exercise.sets.isEmpty)
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
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(workoutTitle: .constant(""))
    }
}

