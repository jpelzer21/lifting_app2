import SwiftUI
import FirebaseFirestore

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    private let calendar = Calendar.current
    private let year: Int = Calendar.current.component(.year, from: Date())
    
    // Store workout days from Firestore
    @State private var workoutDates: Set<Date> = []
    
    // Track scroll position
    @State private var scrollViewProxy: ScrollViewProxy?
    private let currentMonth: Int = Calendar.current.component(.month, from: Date())

    private var months: [Int: [Date]] {
        var groupedMonths: [Int: [Date]] = [:]
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        
        var currentDate = startOfYear
        while currentDate <= endOfYear {
            let month = calendar.component(.month, from: currentDate)
            groupedMonths[month, default: []].append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return groupedMonths
    }

    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(1...12, id: \.self) { month in
                        if let days = months[month] {
                            VStack(alignment: .leading) {
                                Text("\(monthName(for: month)) \(year)")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                    .id(month)

                                // Days of the week header
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                    ForEach(daysOfWeek, id: \.self) { day in
                                        Text(day)
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                
                                // Generate empty spaces for alignment
                                let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
                                let weekday = calendar.component(.weekday, from: firstDayOfMonth) - 1

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                                    ForEach(0..<weekday, id: \.self) { _ in
                                        Text("")
                                            .frame(width: 40, height: 40)
                                    }
                                    
                                    ForEach(days, id: \.self) { date in
                                        Text("\(calendar.component(.day, from: date))")
                                            .frame(width: 40, height: 40)
                                            .background(workoutDates.contains(date) ? Color.pink.opacity(0.8) : Color.gray.opacity(0.2)) // Highlight workout days
                                            .clipShape(Circle())
                                            .onTapGesture {
                                                selectedDate = date
                                            }
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                }
                .padding()
                .onAppear {
                    fetchWorkoutDates()
                    DispatchQueue.main.async {
                        proxy.scrollTo(currentMonth, anchor: .top)
                    }
                }
            }
        }
        .navigationTitle("\(year) Calendar")
    }

    private func fetchWorkoutDates() {
        let db = Firestore.firestore()
        let exercisesRef = db.collection("exercises")

        exercisesRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching exercises: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            var fetchedDates: Set<Date> = []
            
            let group = DispatchGroup()
            
            for document in snapshot.documents {
                let setsRef = exercisesRef.document(document.documentID).collection("sets")
                group.enter()
                
                setsRef.getDocuments { setSnapshot, setError in
                    if let setError = setError {
                        print("Error fetching sets: \(setError.localizedDescription)")
                    } else if let setSnapshot = setSnapshot {
                        for setDoc in setSnapshot.documents {
                            if let timestamp = setDoc.data()["date"] as? Timestamp {
                                let workoutDate = calendar.startOfDay(for: timestamp.dateValue()) // Normalize time
                                fetchedDates.insert(workoutDate)
                            }
                        }
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.workoutDates = fetchedDates
            }
        }
    }

    private func monthName(for month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let date = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        return dateFormatter.string(from: date)
    }
}
