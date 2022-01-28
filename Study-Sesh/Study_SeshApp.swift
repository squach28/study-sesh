//
//  Study_SeshApp.swift
//  Study-Sesh
//
//  Created by Sean Quach on 1/26/22.
//

import SwiftUI
import Firebase

@main
struct Study_SeshApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
