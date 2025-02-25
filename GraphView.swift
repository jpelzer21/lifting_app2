import SwiftUI
import Charts
import FirebaseFirestore


struct GraphView: View {
    @State private var exerciseSets: [ExerciseSet] = []
    @State private var selectedMetric: Metric = .weight
    let exerciseName: String
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4),
                                                                    Color.accentColor.opacity(0)]),
                                                                    startPoint: .top,
                                                                    endPoint: .bottom)
    
    enum Metric: String, CaseIterable {
            case weight = "Weight"
            case reps = "Reps"
            case volume = "Volume"
        }

    var body: some View {
        VStack {
            Text(exerciseName.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.largeTitle)
                .bold()
                .padding()
            Picker("Metric", selection: $selectedMetric) {
                ForEach(Metric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            if exerciseName.isEmpty {
                Text("Loading data...")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart(exerciseSets) { set in
                    LineMark(
                        x: .value("Date", set.date),
                        y: .value(selectedMetric == .weight ? "Weight" : selectedMetric == .reps ? "Reps" : "Volume",
                                  selectedMetric == .weight ? set.weight : selectedMetric == .reps ? Double(set.reps) : set.weight * Double(set.reps))
                    )
                    .symbol(.circle)
                    .interpolationMethod(.catmullRom)
                    
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) {
                        AxisValueLabel(format: .dateTime.month().day()) // Format for better readability
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing)
                }
                .frame(height: 300)
                .padding()
            }
        }
        .onAppear {
            fetchSets(name: exerciseName)
        }
    }

    private func fetchSets(name: String) {
        let db = Firestore.firestore()
        let exerciseRef = db.collection("exercises").document(name).collection("sets")

        exerciseRef.order(by: "date", descending: false).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching bench press sets: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                self.exerciseSets = snapshot.documents.compactMap { doc in
                    let data = doc.data()
                    guard let timestamp = data["date"] as? Timestamp,
                          let weight = data["weight"] as? Double,
                          let reps = data["reps"] as? Int else { return nil }

                    return ExerciseSet(number: 0, weight: weight, reps: reps, date: timestamp.dateValue())
                }
            }
        }
    }
}
