//
//  AvenueITApp.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct AvenueITApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @State private var locationManager = LocationManager() // for identifying user location

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    MainDashboardView()
                } else {
                    LoginView()
                }
            }
            .environment(locationManager)
        }
    }
}
