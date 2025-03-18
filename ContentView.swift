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
            NavigationStack {
                HomePageView()
                    .navigationTitle("Home")
            }
            .tabItem {
                Text("Home")
                Image(systemName: "house.fill")
                    .renderingMode(.template)
            }
            .tag(0)
            
            
            NavigationStack() {
                ExerciseListView()
                    .navigationTitle("Data Visualization")
            }
            .tabItem {
                Text("Data")
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
//            .badge("12")
            .tag(1)
            .navigationBarTitleDisplayMode(.inline)


            
            
            NavigationStack() {
                CalendarView()
                    .navigationTitle("Calendar")
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            .tag(2)
            
        }
        .tint(.pink)
        .onAppear(perform: {
            
            UITabBar.appearance().unselectedItemTintColor = .systemBrown
            UITabBarItem.appearance().badgeColor = .systemPink
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemPink]
        })
    }
}
