import SwiftUI
import Charts
import FirebaseFirestore
import FirebaseAuth

struct GraphView: View {
    @State private var exerciseSets: [ExerciseSet] = []
    @State private var selectedMetric: Metric = .volume
    let exerciseName: String
//    let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4),
//                                                                    Color.accentColor.opacity(0)]),
//                                                                    startPoint: .top,
//                                                                    endPoint: .bottom)
    
    enum Metric: String, CaseIterable {
            case weight = "Weight"
            case reps = "Reps"
            case volume = "Volume"
        }
    
    private var maxYAxisValue: Double {
        let maxValue: Double
        switch selectedMetric {
        case .weight:
            maxValue = exerciseSets.map { $0.weight }.max() ?? 0
        case .reps:
            maxValue = Double(exerciseSets.map { $0.reps }.max() ?? 0)
        case .volume:
            maxValue = exerciseSets.map { $0.weight * Double($0.reps) }.max() ?? 0
        }
    return maxValue * 1.25 // Double the maximum value for better scaling
    }
    
    private var minYAxisValue: Double {
        let minValue: Double
        switch selectedMetric {
        case .weight:
            minValue = exerciseSets.map { $0.weight }.min() ?? 0
        case .reps:
            minValue = Double(exerciseSets.map { $0.reps }.min() ?? 0)
        case .volume:
            minValue = exerciseSets.map { $0.weight * Double($0.reps) }.min() ?? 0
        }
        return minValue
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
            if exerciseSets.isEmpty {
                Text("Loading data...")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart {
                    ForEach(exerciseSets) { set in
                        PointMark(
                            x: .value("Date", set.date),
                            y: .value(selectedMetric.rawValue,
                                      selectedMetric == .weight ? set.weight :
                                      selectedMetric == .reps ? Double(set.reps) :
                                      set.weight * Double(set.reps))
                        )
                        .symbol(.circle)
                        .opacity(1/Double(set.number))
                        .foregroundStyle(Color.pink)
                    }
                    
                    let firstSets = exerciseSets.filter { $0.number == 1 }
                    ForEach(Array(firstSets.enumerated()), id: \.element.id) { index, set in
                            LineMark(
                                x: .value("Date", set.date),
                                y: .value(selectedMetric.rawValue,
                                          selectedMetric == .weight ? set.weight :
                                          selectedMetric == .reps ? Double(set.reps) :
                                          set.weight * Double(set.reps))
                            )
                            .foregroundStyle(Color.pink)
                            .lineStyle(StrokeStyle(lineWidth: 2)) // Dashed line for clarity
                    }
                    
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) {
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing)
                }
                .chartYScale(domain: minYAxisValue...maxYAxisValue)
                .frame(height: 300)
                .padding()

            }
        }
        .onAppear {
            fetchSets(name: exerciseName)
        }
    }
    
    private func fetchSets(name: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in")
            return
        }
        let db = Firestore.firestore()
        let exerciseRef = db.collection("users").document(userID)
            .collection("exercises").document(name)
            .collection("sets")

        exerciseRef.order(by: "date", descending: false).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching sets: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                self.exerciseSets = snapshot.documents.compactMap { doc in
                    let data = doc.data()
                    guard let timestamp = data["date"] as? Timestamp,
                          let weight = data["weight"] as? Double,
                          let reps = data["reps"] as? Int,
                          let setNum = data["setNum"] as? Int else { return nil }

                    return ExerciseSet(number: setNum, weight: weight, reps: reps, date: timestamp.dateValue())
                }
            }
        }
    }
}
