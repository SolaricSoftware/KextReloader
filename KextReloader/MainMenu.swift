//
//  MainMenuController.swift
//  KextReloader
//
//  Created by Olan Hall on 12/5/14.
//  Copyright (c) 2014 Solaic Software. All rights reserved.
//

import Cocoa

class MainMenu: NSObject {
    @IBOutlet var menu: NSMenu!;
    @IBOutlet var miLoad: NSMenuItem!;
    
    private var _statusBar = NSStatusBar.systemStatusBar();
    private var _statusBarItem: NSStatusItem!;
    private var _controller: NSWindowController!;
    
    override func awakeFromNib() {
        _statusBarItem = _statusBar.statusItemWithLength(-1);
        _statusBarItem.menu = menu;
        _statusBarItem.highlightMode = true;
        _statusBarItem.image = NSImage(named: "KextReloaderIcon32_v2");
    }
    
    @IBAction func menuItemLoadSelected(sender: NSMenuItem) {
        NSLog("Load Selected");
    }
    
    @IBAction func menuItemUnloadSelected(sender: NSMenuItem) {
        NSLog("Unload Selected");
    }
    
    @IBAction func menuItemSelectKextFilesSelected(sender: NSMenuItem) {
        NSLog("Select Kext Files Selected");
        
        var psn: ProcessSerialNumber = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: 2);
        TransformProcessType(&psn, ProcessApplicationTransformState(kProcessTransformToForegroundApplication));
        
        _controller = KextSelect();
        _controller.showWindow(self);
        
//        var km:KextManager = KextManager(kextObjectLoaded);
        
        //(_controller as KextSelect).kextManager.data.count;
    }
    
//    func kextObjectLoaded(e: KextObjectEventArgs) {
//        NSLog("Name: %@", e.item.name);
//
//        (_controller as KextSelect).lblFileName.stringValue = e.item.name;
//        (_controller as KextSelect).piProgress.doubleValue = Double(e.currentCount / e.totalCount);
//    }
    
    @IBAction func menuItemPreferencesSelected(sender: NSMenuItem) {
        NSLog("Preferences Selected");
    }
    
    @IBAction func menuItemQuitSelected(sender: NSMenuItem) {
        NSLog("Quit Selected");
        NSRunningApplication.currentApplication().terminate();
    }
}
