import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ExerciseListView: View {
    @State private var exercises: [(name: String, setCount: Int?, lastSetDate: Date?)] = []
    @State private var isLoading = true
    @State private var showSortOptions = false
    @State private var selectedSortOption: String = "Alphabetical"
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    showSortOptions.toggle()
                }) {
                    HStack {
                        Text("Sort: \(selectedSortOption) ⌄")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                .actionSheet(isPresented: $showSortOptions) {
                    ActionSheet(title: Text("Sort By"), buttons: [
                        .default(Text("Most Recent")) { selectSortOption("Most Recent") },
                        .default(Text("Most Sets")) { selectSortOption("Largest Set Count") },
                        .default(Text("Alphabetical")) { selectSortOption("Alphabetical") },
                        .cancel()
                    ])
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                
                if isLoading {
                    VStack {
                        ProgressView("Loading...")
                            .padding()
                    }
                } else if exercises.isEmpty {
                    VStack(alignment: .center) {
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
                                        lastSetDate: exercise.lastSetDate
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal).padding(.top, 20)
                    }
                    .navigationTitle("Exercises")
                }
            }
        }
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
        case "Largest Set Count":
            query = query.order(by: "setCount", descending: true)
        case "Alphabetical":
            query = query.order(by: "name", descending: false)
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
}
