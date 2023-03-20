//
//  AppDelegate.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 06/04/2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var windowController: MainWindowController!
    @IBOutlet weak var openMenuItem: NSMenuItem!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        windowController = MainWindowController(menuItem: openMenuItem)
        windowController.showImportView()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            windowController.showImportView()
        }
        
        return false
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        
        windowController.open(url: url)
    }
    
    @IBAction func reopenIfNeeded(_ sender: Any) {
        windowController.unminiutarizeOrShowImportView()
    }
}

