//
//  KextObject.swift
//  KextReloader
//
//  Created by Olan Hall on 12/5/14.
//  Copyright (c) 2014 Solaic Software. All rights reserved.
//

import Cocoa

class KextObject : NilLiteralConvertible {
    var isSelected: Bool = false;
    var name:String = "";
    var execName:String = ""
    var bundleId:String = "";
    var isLoaded:Bool = false;  
    
    init() {
        
    }
    
    required init(nilLiteral: ()) {
        
    }
}

struct KextObjectEventArgs {
    var totalCount:Int = 0;
    var currentCount:Int = 0;
    var item:KextObject!;
}

class KextManager: NSObject {
    var _data = [KextObject]();
    var data: [KextObject] {
        get {
            return _data;
        }
    }
    
    var _checkLoaded:Bool = false;
    var checkLoaded: Bool {
        get {
            return _checkLoaded;
        }
    }
    
//    override init() {
//        super.init();
//    }
    
    init(checkForLoaded:Bool) {
        super.init();
        
        self._checkLoaded = checkForLoaded;
    }
    
    func addKextObject(kextObject:KextObject) {
        _data.append(kextObject);
    }
    
    func getAtIndex(index:Int) -> KextObject {
        if(index > _data.count) {
            return nil;
        }
        
        return _data[index];
    }
    
    func saveData() {
        let path = NSBundle.mainBundle().pathForResource("KextData", ofType: "plist");
        var plist = NSMutableDictionary(contentsOfFile: path!);
        plist?.removeAllObjects();
        
        for i in 0...(self.data.count-1) {
            var obj = self.getAtIndex(i);
            
            if(obj.isSelected) {
                var objDic = NSMutableDictionary();
                objDic.setObject(obj.isSelected, forKey: "isSelected");
                objDic.setObject(obj.name, forKey: "name");
                objDic.setObject(obj.bundleId, forKey: "bundleId");
                objDic.setObject(obj.execName, forKey: "fileName");
                
                plist?.setObject(objDic, forKey: obj.execName);
            }
        }
        
        plist?.writeToFile(path!, atomically: true);
    }
    
    func loadData(action: (KextObjectEventArgs) -> Void) {
        var kextObjects = getKextObjects();
        
        for(var i:Int = 0; i < kextObjects.count; i++) {
            var obj = kextObjects[i];
            
            if(self._checkLoaded) {
                obj.isLoaded = self.isKextLoaded(obj.bundleId);
            } else {
                obj.isLoaded = false;
            }
            
            self.addKextObject(obj);
            var e = KextObjectEventArgs(totalCount: kextObjects.count, currentCount: i + 1, item: obj);
            action(e);
        }
    }
    
    private func getKextObjects() -> [KextObject] {
        var retVal: [KextObject] = [];
        let fm = NSFileManager.defaultManager();
        let path = NSBundle.mainBundle().pathForResource("KextData", ofType: "plist");
        var plistDic = path != nil ? NSDictionary(contentsOfFile: path!) : NSDictionary();
        
        var error:NSError?;
        if var files = fm.contentsOfDirectoryAtPath("/System/Library/Extensions/", error:&error) as [String]! {
            var counter:Int = 0;
            
            for file in files {
                var infoPath: String = String(NSString(format: "/System/Library/Extensions/%@/Contents/info.plist", file));
                var plist = NSDictionary(contentsOfFile: infoPath);
                if var packageType:String = plist?.objectForKey("CFBundlePackageType") as? String {
                    var obj:KextObject = KextObject();
                    
                    if(!packageType.isEmpty && packageType == "KEXT") {
                        counter++;
                        
                        let range = file.rangeOfString(".")!;
                        obj.execName = file.substringToIndex(range.startIndex);
                        obj.bundleId = plist?.objectForKey("CFBundleIdentifier") as String!;
                        
                        let range2 = obj.bundleId.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch)!;
                        obj.name = obj.bundleId.substringFromIndex(range2.endIndex);
                        
                        obj.isSelected = plistDic?.objectForKey(obj.execName) != nil;
                        
                        retVal.append(obj);
                    }
                }
            }
        }
        
        return retVal;
    }
    
    private func isKextLoaded(bundleId:String) -> Bool {
        var cmd = String(NSString(format: "/usr/sbin/kextstat | /usr/bin/grep -qF %@", bundleId));
        //NSLog("Command: %@", cmd);
        var v = system(cmd);
        return (v == 0);
    }
}
