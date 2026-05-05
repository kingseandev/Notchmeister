//
//  AppDelegate.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	private var statusItem: NSStatusItem?

	var needsActivation = false {
		didSet {
			debugLog("needsActivation = \(needsActivation)")
		}
	}
	
	override init() {
		super.init()
		Defaults.register()
		// Personal fork: keep notch clicks available to DropNotch.
		Defaults.shouldActivateUnderNotch = false
	}
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		if Defaults.shouldHideDockIcon {
			NSApplication.shared.setActivationPolicy(.accessory)
			NSApplication.shared.activate(ignoringOtherApps: true)
		}
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		configureStatusItem()
		
#if !DEBUG
		if !NSScreen.hasNotchedScreen {
			let alert = NSAlert()
			alert.messageText = "Notch Simulation Mode"
			alert.informativeText = Defaults.notchlessHelp + Defaults.notchlessHelpIntro
			alert.runModal()
			
			Defaults.shouldFakeNotch = true
		}
		else {
			Defaults.shouldFakeNotch = false
		}
#endif
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true;
	}

	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		// clicking on the Dock icon will cause the main window to reappear
		if let window = sender.windows.first {
			window.makeKeyAndOrderFront(self)
		}
		return false
	}

	func applicationDidResignActive(_ notification: Notification) {
		debugLog()
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		debugLog("windows = \(NSApp.windows.map { $0.title })")
	}
	
	@IBAction func openGitHub(_ sender: Any) {
		NSWorkspace.shared.open(Defaults.gitHubUrl)
	}

	@IBAction func openWindow(_ sender: Any) {
		NSApplication.shared.activate(ignoringOtherApps: true)
		if let window = NSApplication.shared.windows.first {
			window.makeKeyAndOrderFront(self)
		}
	}

	@IBAction func quitApplication(_ sender: Any) {
		NSApplication.shared.terminate(self)
	}

	private func configureStatusItem() {
		let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		if let button = statusItem.button {
			button.title = "NM"
			button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "Notchmeister")
			button.image?.isTemplate = true
			button.imagePosition = .imageLeading
			button.toolTip = "Notchmeister"
		}

		let menu = NSMenu(title: "Notchmeister")
		menu.addItem(menuItem(title: "Settings...", action: #selector(openWindow(_:)), keyEquivalent: ","))
		menu.addItem(.separator())
		menu.addItem(menuItem(title: "Quit Notchmeister", action: #selector(quitApplication(_:)), keyEquivalent: "q"))
		statusItem.menu = menu

		self.statusItem = statusItem
	}

	private func menuItem(title: String, action: Selector, keyEquivalent: String) -> NSMenuItem {
		let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
		item.target = self
		return item
	}
	
}
