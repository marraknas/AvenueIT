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
            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // TODO: Finish up all the screens so that it can navigate
            
            Text("Map View (TODO)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.avenueDeepNavy)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)

            Text("My Events View (TODO)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.avenueDeepNavy)
                .tabItem {
                    Label("My Events", systemImage: "ticket")
                }
                .tag(2)
            
            Text("Profile View (TODO)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.avenueDeepNavy)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
        .tint(Color.avenueNeonCyan)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainDashboardView()
}
