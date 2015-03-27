//
//  Preferences.swift
//  KextReloader
//
//  Created by Olan Hall on 3/26/15.
//  Copyright (c) 2015 Solaic Software. All rights reserved.
//

import Cocoa

class Preferences : NSWindowController, NSWindowDelegate {
    @IBOutlet var btnAutoStart:NSButton!;
    @IBOutlet var btnCheckLoaded:NSButton!;
    
    override convenience init() {
        self.init(windowNibName: "Preferences");
    }
    
    override func windowDidLoad() {
        NSLog("Preferences Loaded");
        
        let itemReferences = itemReferencesInLoginItems();
        let isStartupItem = (itemReferences.existingReference != nil);
        btnAutoStart.state = isStartupItem ? NSOnState : NSOffState;
        
        var checkLoaded = NSUserDefaults.standardUserDefaults().boolForKey("IncludeIsLoaded");
        btnCheckLoaded.state = checkLoaded ? NSOnState : NSOffState;
    }
    
    @IBAction func autoStartClick(sender: NSButton) {
        setAsStartUpItem(sender.state == NSOnState);
    }
    
    @IBAction func checkLoadedClick(sender: NSButton) {
        NSUserDefaults.standardUserDefaults().setBool(sender.state == NSOnState, forKey: "IncludeIsLoaded");
    }
    
    func setAsStartUpItem(startUp:Bool) {
        let itemReferences = itemReferencesInLoginItems();
        let isAlreadyStartUpItem = (itemReferences.existingReference != nil);
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileListRef?;
        
        if loginItemsRef != nil {
            if startUp && !isAlreadyStartUpItem {
                if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                    LSSharedFileListInsertItemURL(
                        loginItemsRef,
                        itemReferences.lastReference,
                        nil,
                        nil,
                        appUrl,
                        nil,
                        nil
                    );
                    println("Application was added to login items");
                }
            } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
                    println("Application was removed from login items");
                }
            }
        }
    }
    
    func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil);
    }
    
    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
        var itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
        if let appUrl : NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
            let loginItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                nil
                ).takeRetainedValue() as LSSharedFileListRef?
            if loginItemsRef != nil {
                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
                println("There are \(loginItems.count) login items")
                let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as LSSharedFileListItemRef
                for var i = 0; i < loginItems.count; ++i {
                    let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as LSSharedFileListItemRef
                    if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                        if let urlRef: NSURL =  itemUrl.memory?.takeRetainedValue() {
                            println("URL Ref: \(urlRef.lastPathComponent)")
                            if urlRef.isEqual(appUrl) {
                                return (currentItemRef, lastItemRef)
                            }
                        }
                    } else {
                        println("Unknown login application")
                    }
                }
                //The application was not found in the startup list
                return (nil, lastItemRef)
            }
        }
        return (nil, nil)
    }
}
