//
//  HomePageViewModel.swift
//  lift
//
//  Created by Josh Pelzer on 3/21/25.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class HomePageViewModel: ObservableObject {
    @Published var templates: [WorkoutTemplate] = []
    @Published var isLoading = false

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        fetchTemplatesRealtime()
    }

    /// Fetch workout templates and listen for real-time updates
    func fetchTemplatesRealtime() {
        guard let userID = userID else { return }
        
        isLoading = true

        listener = db.collection("users").document(userID).collection("templates")
            .order(by: "lastEdited", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    print("❌ Error fetching templates: \(error.localizedDescription)")
                    self.templates = []
                    return
                }

                self.templates = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    let name = doc.documentID.replacingOccurrences(of: "_", with: " ").capitalized
                    let exercises = (data["exercises"] as? [[String: Any]])?.compactMap { exerciseDict -> Exercise? in
                        guard let name = exerciseDict["name"] as? String else { return nil }
                        let sets = (exerciseDict["sets"] as? [[String: Any]])?.compactMap { setDict -> ExerciseSet? in
                            let setNum = setDict["setNum"] as? Int ?? 0
                            let weight = setDict["weight"] as? Double ?? 0.0
                            let reps = setDict["reps"] as? Int ?? 0
                            return ExerciseSet(number: setNum, weight: weight, reps: reps)
                        } ?? []
                        
                        return Exercise(name: name, sets: sets)
                    } ?? []
                    return WorkoutTemplate(id: doc.documentID, name: name, exercises: exercises)
                } ?? []
            }
    }

    /// Delete a template from Firestore
    func deleteTemplate(templateID: String) {
        guard let userID = userID else { return }

        db.collection("users").document(userID).collection("templates").document(templateID)
            .delete { [weak self] error in
                if let error = error {
                    print("❌ Error deleting template: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self?.templates.removeAll { $0.id == templateID }
                    }
                }
            }
    }

    /// Stop listening to Firestore updates when the ViewModel is deinitialized
    deinit {
        listener?.remove()
    }
}