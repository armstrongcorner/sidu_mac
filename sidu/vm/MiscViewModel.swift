//
//  MiscViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 21/09/2024.
//

import Foundation
import AppKit

@Observable
class MiscViewModel {
    var isShowingConfirmRestart: Bool = false
    
    func restartApp() {
        // Restart the app
        if let url = URL(string: Bundle.main.bundlePath) {
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [url.path]
            task.launch()
            NSApplication.shared.terminate(nil)
        }
    }
}
