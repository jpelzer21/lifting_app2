//
//  LoginView.swift
//  lift
//
//  Created by Josh Pelzer on 3/13/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var weight = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var isSignedIn: Bool = false
    @State private var isRegistering = false // Toggle between Login and Signup
    @State private var authListener: AuthStateDidChangeListenerHandle?
    
    var body: some View {
        if isSignedIn {
            ContentView()
        } else {
            content
        }
    }
    
    var content: some View {
        VStack {
            Text(isRegistering ? "Create an Account" : "Welcome Back!")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            if isRegistering {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .padding(.horizontal)
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .padding(.horizontal)
                TextField("Weight", text: $weight)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .padding(.horizontal)
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            
            Button(action: isRegistering ? register : signIn) {
                Text(isLoading ? (isRegistering ? "Creating Account..." : "Signing In...") : (isRegistering ? "Sign Up" : "Sign In"))
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(isLoading)

            Button(action: { isRegistering.toggle() }) {
                Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .foregroundColor(.pink)
            }
        }
        .onAppear {
            authListener = Auth.auth().addStateDidChangeListener { _, user in
                if user != nil {
                    isSignedIn = true
                }
            }
        }
        .onDisappear {
            if let authListener = authListener {
                Auth.auth().removeStateDidChangeListener(authListener)
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .padding()
    }
    
    // MARK: - Sign In Function
    func signIn() {
        print("SIGN IN() CALLED")
        isLoading = true
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                print("✅ User signed in: \(result?.user.email ?? "")")
            }
        }
    }
    
    // MARK: - Register Function (Stores User Info in Firestore)
    func register() {
        print("REGISTER() CALLED")
        isLoading = true
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let user = result?.user {
                saveUserData(user: user)
                print("✅ User registered: \(user.email ?? "")")
            }
        }
    }
    
    // MARK: - Save User Info to Firestore
    func saveUserData(user: User) {
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData([
            "uid": user.uid,
            "firstName": firstName,
            "lastName": lastName,
            "weight": weight,
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("❌ Error saving user data: \(error.localizedDescription)")
            } else {
                print("✅ User data successfully saved in Firestore!")
            }
        }
    }
}
