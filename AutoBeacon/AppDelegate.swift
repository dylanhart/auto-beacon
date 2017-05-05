//
//  AppDelegate.swift
//  AutoBeacon
//
//  Created by Dylan Hart on 5/4/17.
//  Copyright © 2017 Dylan Hart. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var statusMenu: NSMenu!

    var statusItem: NSStatusItem = NSStatusItem()
    var popover: NSPopover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system()

        statusItem = statusBar.statusItem(withLength: NSVariableStatusItemLength)
        statusItem.title = "AutoBeacon"
//        statusItem.menu = statusMenu
        statusItem.action = #selector(self.togglePopover(sender:))

        let popController = MainViewController(nibName: "MainViewController", bundle: nil)
        popover.contentViewController = popController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            let button = statusItem.button!
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
}

