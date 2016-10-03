//
//  Technique.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 23/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class Technique: NSManagedObject, PlaylistItem {
    
    var isInPlaylist: Bool {
        get { return inPlaylist }
        set { inPlaylist = newValue }
    }
    
    /** Returns all Technique objects, in the correct order. */
    class func orderedTechniques(context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> [Technique] {
        let fetch = NSFetchRequest(entityName: Technique.entityName)
        fetch.sortDescriptors = [NSSortDescriptor(key: "ordinal", ascending: true)]
        do { return (try context.executeFetchRequest(fetch) as? [Technique]) ?? [] }
        catch { return [] }
    }
    
    var remoteMediaURL: NSURL? {
        get {
            if let path = remoteMediaPath {
                return NSURL(fileURLWithPath: path)
            }
            return nil
        }
    }
    
    var localMediaURL: NSURL {
        get {
            if let path = localMediaPath {
                let components = path.componentsSeparatedByString(".")
                if components.count >= 2, let ext = components.last {
                    let name = components[0..<components.count-1].joinWithSeparator(".")
                    if let url = NSBundle.mainBundle().URLForResource(name, withExtension: ext) {
                        return url
                    }
                }
            }
            
            return NSBundle.mainBundle().URLForResource("default_movie", withExtension: "mov")!
        }
    }
    
    var localMediaThumbURL: NSURL {
        get {
            if let path = localMediaThumbPath {
                let components = path.componentsSeparatedByString(".")
                if components.count >= 2, let ext = components.last {
                    let name = components[0..<components.count-1].joinWithSeparator(".")
                    if let url = NSBundle.mainBundle().URLForResource(name, withExtension: ext) {
                        return url
                    }
                }
            }
            
            return NSBundle.mainBundle().URLForResource("default_movie", withExtension: "mov")!
        }
    }
    
    var thumbURL: NSURL {
        get {
            if let path = thumbPath {
                let components = path.componentsSeparatedByString(".")
                if components.count >= 2, let ext = components.last {
                    let name = components[0..<components.count-1].joinWithSeparator(".")
                    if let url = NSBundle.mainBundle().URLForResource(name, withExtension: ext) {
                        return url
                    }
                }
            }
            
            return NSBundle.mainBundle().URLForResource("default_thumb", withExtension: "png")!
        }
    }
    
    private var _thumbCache: UIImage?
    var thumbnail: UIImage {
        get {
            if let thumb = _thumbCache { return thumb }
            precache()
            return _thumbCache!
        }
    }
    
    func precache() {
        if let data = NSData(contentsOfURL: thumbURL) {
            _thumbCache = UIImage(data: data)
        }
    }
    
}

extension Technique: JSONConfigurable {
    
    func configure(json: JSON) throws {
        name = try json["name"].string.unwrap("Technique Name")
        detail = try json["detail"].string.unwrap("Technique Detail")
        level = try json["level"].string.unwrap("Technique level")
        step1 = try json["step1"].string.unwrap("Technique step 1")
        step2 = try json["step2"].string.unwrap("Technique step 2")
        step3 = try json["step3"].string.unwrap("Technique step 3")
        
        remoteMediaPath = json["remote_path"].string
        localMediaPath = json["local_path"].string
        localMediaThumbPath = json["local_path_thumb"].string
        thumbPath = json["thumb_path"].string
    }
}