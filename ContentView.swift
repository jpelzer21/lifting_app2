//
//  ContentView.swift
//  lift
//
//  Created by Josh Pelzer on 2/23/25.
//
import SwiftUI

struct ContentView: View {
    @State private var selectedIndex: Int = 0

    var body: some View {
        TabView(selection: $selectedIndex) {
            NavigationStack() {
                HomePageView()
                    .navigationTitle("Home")
            }
            .tabItem {
                Text("Home View")
                Image(systemName: "house.fill")
                    .renderingMode(.template)
            }
            .tag(0)
            
            
            NavigationStack() {
                ExerciseListView()
                    .navigationTitle("Data Visualization")
            }
            .tabItem {
                Text("Data ")
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
//            .badge("12")
            .tag(1)
            
            
            NavigationStack() {
                Text("Profile view")
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(2)
            
        }
        .tint(.pink)
        .onAppear(perform: {
            //2
            UITabBar.appearance().unselectedItemTintColor = .systemBrown
            //3
            UITabBarItem.appearance().badgeColor = .systemPink
            //4
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
            //5
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemPink]
            //UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
            //Above API will kind of override other behaviour and bring the default UI for TabView
        })
    }
}
