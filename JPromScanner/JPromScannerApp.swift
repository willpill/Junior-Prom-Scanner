//
//  JPromScannerApp.swift
//  JPromScanner
//
//  Created by Yinwei Z on 10/28/23.
//

import SwiftUI

@main
struct JPromScannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
