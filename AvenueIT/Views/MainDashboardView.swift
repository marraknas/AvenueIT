//
//  MainDashboardView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI

struct MainDashboardView: View {
    @State private var selectedScreen = 0
    var body: some View {
        TabView(selection: $selectedScreen) {

            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)

            MyEventsView()
                .tabItem {
                    Label("My Events", systemImage: "bookmark.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
        .tint(Color.avenueNeonCyan)
        .preferredColorScheme(.dark)
    }
}
