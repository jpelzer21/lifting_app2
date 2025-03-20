import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var userViewModel = UserViewModel.shared // Use the shared instance
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Image
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 30)

                // Profile Info Card
                VStack(spacing: 10) {
                    Text(userViewModel.userName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Weight: \(userViewModel.weight) lbs")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Text(userViewModel.userEmail)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal, 20)

                // Navigation Buttons
                VStack(spacing: 10) {
                    NavigationLink(destination: CalendarView()) {
                        CustomButton(title: "View Calendar", color: .blue)
                    }
                    NavigationLink(destination: HistoryView()) {
                        CustomButton(title: "Workout History", color: .pink)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Logout Button
                Button {
                    showingAlert = true
                } label: {
                    CustomButton(title: "Log Out", color: .red)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Log Out?"),
                        message: Text("Are you sure you want to sign out?"),
                        primaryButton: .destructive(Text("Yes")) {
                            signOut()
                        },
                        secondaryButton: .cancel()
                    )
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }

    // Sign Out Function
    private func signOut() {
        print("SIGN OUT() CALLED")
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss()
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

// Custom Button Modifier
struct CustomButton: View {
    var title: String
    var color: Color
    
    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 5)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
