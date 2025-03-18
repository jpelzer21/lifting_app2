import SwiftUI
import Charts
import FirebaseFirestore
import FirebaseAuth

struct GraphView: View {
    @State private var exerciseSets: [ExerciseSet] = []
    @State private var selectedMetric: Metric = .volume
    @State private var isLoading = true
    let exerciseName: String
    
    enum Metric: String, CaseIterable {
            case weight = "Weight"
            case reps = "Reps"
            case volume = "Volume"
        }
    
    private var maxYAxisValue: Double {
        let maxValue = exerciseSets.map { metricValue(for: $0) }.max() ?? 0
        return maxValue * 1.25
    }

    private var minYAxisValue: Double {
        let minValue = exerciseSets.map { metricValue(for: $0) }.min() ?? 0
        return max(0, minValue-(minValue*0.25))
    }

    var body: some View {
        let firstSets = exerciseSets.filter { $0.number == 1 }
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
            if isLoading {
                ProgressView("Loading exercise data...")
                    .padding()
            } else {
                if exerciseSets.isEmpty {
                    VStack {
                        Text("No recorded sets for this exercise.")
                            .foregroundColor(.gray)
                    }
                } else {
                    if firstSets.count > 1 {
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
                            
                            ForEach(Array(firstSets.enumerated()), id: \.element.id) { index, set in
                                LineMark(
                                    x: .value("Date", set.date),
                                    y: .value(selectedMetric.rawValue, metricValue(for: set))
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
                    } else {
                        Text("Not enough data to display a trend.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            fetchSets(name: exerciseName)
        }
    }
    
    private func metricValue(for set: ExerciseSet) -> Double {
        switch selectedMetric {
        case .weight: return set.weight
        case .reps: return Double(set.reps)
        case .volume: return set.weight * Double(set.reps)
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

        exerciseRef.order(by: "date").getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetching sets: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            isLoading = false
            self.exerciseSets = snapshot.documents.compactMap { doc in
                let data = doc.data()
                return ExerciseSet(
                    number: data["setNum"] as? Int ?? 1,
                    weight: data["weight"] as? Double ?? 0,
                    reps: data["reps"] as? Int ?? 0,
                    date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
                )
            }
        }
    }
    
}
