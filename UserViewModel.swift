//
//  UserViewModel.swift
//  lift
//
//  Created by Josh Pelzer on 3/20/25.
//


import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var userName: String = "Loading..."
    @Published var weight: String = "Loading..."
    @Published var userEmail: String = "Loading..."
    
    static let shared = UserViewModel() // Singleton instance

    private var hasFetched = false // Prevent duplicate fetches

    init() {
        fetchUserData()
    }
    
    func fetchUserData() {
        guard !hasFetched else { return } // Prevent duplicate fetch
        print("FETCH USER DATA() CALLED")
        guard let user = Auth.auth().currentUser else { return }
        
        userEmail = user.email ?? "No Email"
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user data: \(error.localizedDescription)")
            } else if let data = snapshot?.data() {
                let first = data["firstName"] as? String ?? "No"
                let last = data["lastName"] as? String ?? "Name"
                DispatchQueue.main.async {
                    self.userName = "\(first) \(last)"
                    self.weight = data["weight"] as? String ?? "0"
                    self.hasFetched = true // Mark as fetched
                }
            }
        }
    }
}