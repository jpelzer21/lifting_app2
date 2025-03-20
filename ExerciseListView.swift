import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ExerciseListView: View {
    @State private var exercises: [(name: String, setCount: Int?, lastSetDate: Date?)] = []
    @State private var isLoading = true
    @State private var showSortOptions = false
    @State private var selectedSortOption: String = "Most Recent"
    @State private var isDeleting = false
    @State private var exerciseToDelete: String?
    @State private var showDeleteConfirmation = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
//        NavigationView {
            VStack (spacing: 0) {
                
                NavigationLink(destination: HistoryView()) {
                    Text("History")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(10)
                }
                .padding(.leading, 20)
                
                HStack {
                    Button(action: {
                        showSortOptions.toggle()
                    }) {
                        HStack {
                            Text("Sort: \(selectedSortOption)")
                                .font(.headline)
                                .foregroundColor(.pink)
                        }
                        .padding()
                    }
                    .actionSheet(isPresented: $showSortOptions) {
                        ActionSheet(title: Text("Sort By"), buttons: [
                            .default(Text("Most Recent")) { selectSortOption("Most Recent") },
                            .default(Text("Most Sets")) { selectSortOption("Most Sets") },
                            .default(Text("A-Z")) { selectSortOption("Alphabetical A-Z") },
                            .default(Text("Z-A")) { selectSortOption("Alphabetical Z-A") },
                            .cancel()
                        ])
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 20)
                    
                    Button(action: { isDeleting.toggle() }) {
                        Image(systemName: isDeleting ? "ellipsis.rectangle.fill" : "ellipsis")
                            .imageScale(.large)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 10, height: 10)
                            .foregroundColor(.pink)
                            .padding(.vertical, 5)
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 30)
                }
                
                
                if isLoading {
                    VStack {
                        ProgressView("Loading...")
                            .padding()
                    }
                } else if exercises.isEmpty {
                    VStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "dumbbell.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        
                        Text("No exercises yet!")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Add an exercise by making a template!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 100)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(exercises, id: \..name) { exercise in
                                NavigationLink(destination: GraphView(exerciseName: exercise.name)) {
                                    ExerciseCard(
                                        exerciseName: exercise.name,
                                        setCount: exercise.setCount,
                                        lastSetDate: exercise.lastSetDate,
                                        isDeleting: isDeleting,
                                        deleteAction: {
                                            exerciseToDelete = exercise.name
                                            showDeleteConfirmation = true
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal).padding(.top, 10)
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                }
            }
            .padding(.top, 50)
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Exercise"),
                    message: Text("Are you sure you want to delete \"\(exerciseToDelete ?? "")\"? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let exercise = exerciseToDelete {
                            deleteExercise(named: exercise)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationTitle("Exercises")
//        }
//        .navigationTitle("Exercises")
        .onAppear(perform: fetchExercises)
    }
    
    func selectSortOption(_ option: String) {
        selectedSortOption = option
        fetchExercises()
    }
    
    func fetchExercises() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        var query: Query = db.collection("users").document(userID).collection("exercises")
        
        switch selectedSortOption {
        case "Most Recent":
            query = query.order(by: "lastSetDate", descending: true)
        case "Most Sets":
            query = query.order(by: "setCount", descending: true)
        case "Alphabetical A-Z":
            query = query.order(by: "name", descending: false)
        case "Alphabetical Z-A":
            query = query.order(by: "name", descending: true)
        default:
            break
        }
        
        query.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching exercises: \(error.localizedDescription)")
                    self.exercises = []
                } else {
                    self.exercises = snapshot?.documents.map { doc in
                        let name = doc.documentID
                        let setCount = doc.data()["setCount"] as? Int
                        let lastSetTimestamp = doc.data()["lastSetDate"] as? Timestamp
                        let lastSetDate = lastSetTimestamp?.dateValue()
                        return (name: name, setCount: setCount, lastSetDate: lastSetDate)
                    } ?? []
                }
                self.isLoading = false
            }
        }
    }
    
    func deleteExercise(named name: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("exercises").document(name).delete { error in
            if let error = error {
                print("Error deleting exercise: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.exercises.removeAll { $0.name == name }
                }
            }
        }
    }
}
