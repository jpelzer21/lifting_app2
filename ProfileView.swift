//
//  ProfileView.swift
//  lift
//
//  Created by Josh Pelzer on 3/13/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var userName: String = "Loading..."
    @State private var userEmail: String = "Loading..."
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 50)
                
                Text(userName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: signOut) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                fetchUserData()
            }
        }
    }
    
    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }
        userEmail = user.email ?? "No Email"
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user data: \(error.localizedDescription)")
            } else if let data = snapshot?.data() {
                let first = data["firstName"] as? String ?? "No "
                let last = data["lastName"] as? String ?? "Name"
                userName = "\(first) \(last)"
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss()  // Close ProfileView
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = UIHostingController(rootView: LoginView())
                window.makeKeyAndVisible()
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
