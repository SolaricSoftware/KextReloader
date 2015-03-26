//
//  KextSelect.swift
//  KextReloader
//
//  Created by Olan Hall on 12/5/14.
//  Copyright (c) 2014 Solaic Software. All rights reserved.
//

import Cocoa

class KextSelect: NSWindowController, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var vwProgress: NSView!;
    @IBOutlet var vwKextTable: NSScrollView!;

    @IBOutlet var lblFileName: NSTextField!;
    @IBOutlet var lblCurrentCount: NSTextField!;
    @IBOutlet var lblTotalCount: NSTextField!;
    @IBOutlet var lblPercentage: NSTextField!;
    @IBOutlet var piProgress: NSProgressIndicator!;
    @IBOutlet var colLoaded:NSTableColumn!;
    
    private var _km: KextManager!;
     
    override convenience init() {
        self.init(windowNibName: "KextSelect");
    }
    
    override func windowWillLoad() {
        super.windowWillLoad();
    }
    
    override func windowDidLoad() {
        super.windowDidLoad();
        
        piProgress.doubleValue = 0.0;
        
        var include = NSUserDefaults.standardUserDefaults().boolForKey("IncludeIsLoaded");
        
        self.window?.contentView = vwProgress;
        self.window?.showsResizeIndicator = false;
        self.window?.makeKeyAndOrderFront(self);
        
        self._km = KextManager(checkForLoaded: false);
        var kmq = dispatch_queue_create("kextManagerQueue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(kmq) {
            self._km.loadData(self.onDataLoading);
            
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("Async Operation Complete");
                
                self.window?.contentView = self.vwKextTable;
                self.colLoaded.hidden = !self._km.checkLoaded;
                
                return;
            }
        }
        
        NSLog("Kext Select Window Loaded");        
    }
    
    
    @IBAction func onCheckboxClick(sender: NSTableView) {
        var rowIndex = sender.clickedRow;
        var obj = self._km.getAtIndex(rowIndex);
    }
    
    func onDataLoading(e: KextObjectEventArgs) {
        var percentComplete: Double = (Double(e.currentCount) / Double(e.totalCount)) * 100;
        
        NSLog("Name: %@", e.item.name);
        NSLog("Percent Complete: %f", percentComplete);
        
        self.lblFileName.stringValue = e.item.name;
        self.piProgress.doubleValue = percentComplete;
        
        self.lblCurrentCount.integerValue = e.currentCount;
        self.lblTotalCount.integerValue = e.totalCount;
        self.lblPercentage.integerValue = Int(percentComplete);
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        NSLog("Window Closing"); 
        return true;
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if(_km == nil) {
            return 0;
        }
        
        let numberOfRows:Int = _km.data.count;
        return numberOfRows;
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn, row: Int) -> AnyObject? {
        var retVal: AnyObject?;
        var item = _km.getAtIndex(row);
        
        let id = tableColumn.identifier as String;
        
        switch(id) {
            case "bundleId":
                retVal = item.bundleId;
                break;
            case "execName":
                retVal = item.execName;
                break;
            case "isLoaded":
                retVal = item.isLoaded;
                break;
            case "isSelected":
                retVal = item.isSelected;
                break;
            case "name":
                retVal = item.name;
            default:
                
                break;
        }
        
        return retVal;
    }
}
