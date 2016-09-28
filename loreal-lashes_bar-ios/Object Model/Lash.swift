//
//  Lash.swift
//  loreal-lashes_bar-ios
//
//  Created by Igor Nakonetsnoi on 22/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class Lash: Product, PlaylistItem {
    
    override var defaultImageName: String { get { return "brush_default" } }
    
    var isInPlaylist: Bool {
        get { return inPlaylist }
        set { inPlaylist = newValue }
    }
    
    var numberString: String { get { return String(format: "Nº %02d", number) } }
    
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
    
    /** Returns all products associated with this lash, in the correct order. */
//    func orderedAssociates() -> [Product] {
//        guard let associatedProducts = associatedProducts else { return [] }
//        return associatedProducts.sort({ $0.name < $1.name })
//    }
    
    func precache() {
        if let data = NSData(contentsOfURL: thumbURL) {
            _thumbCache = UIImage(data: data)
        }
    }
    
    /** Returns a lash with the given identifying number, or nil if none exists with that number.  */
    class func lashWithNumber(number: Int16, context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> Lash? {
        let request = NSFetchRequest(entityName: self.entityName)
        request.predicate = NSPredicate(format: "number == %d", number)
        request.fetchLimit = 1
        
        do {
            let results = try context.executeFetchRequest(request) as! [Lash]
            if results.count == 0 { return nil }
            return results[0]
        } catch {
            return nil
        }
    }
    
    /** Returns a lash with the given name, or nil if none exists with that name.  */
    class func lashWithName(name: String, context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> Lash? {
        let request = NSFetchRequest(entityName: self.entityName)
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        do {
            let results = try context.executeFetchRequest(request) as! [Lash]
            if results.count == 0 { return nil }
            return results[0]
        } catch {
            return nil
        }
    }
    
    override func configure(json: JSON) throws {
        try super.configure(json)
        number = try json["number"].int16.unwrap("Lash Number")
        detail = try json["detail"].string.unwrap("Lash Detail Text")
        hotTips = try json["hot_tip"].string.unwrap("Lash Alternative Uses")
        length = try json["length"].string.unwrap("Lash Length")
        
        ordinal = number // This may be necessary if lash number changes to a string
        
        remoteMediaPath = json["remote_path"].string
        localMediaPath = json["local_path"].string
        localMediaThumbPath = json["local_path_thumb"].string
        thumbPath = json["thumb_path"].string
        
        if let categoriesJSON = json["categories"].array {
            let identifiers = try categoriesJSON.map({ try $0.string.unwrap("Related Categories Relationship") })
            categories = Set(LashCategory.categoriesWithNames(identifiers))
        }
    }
}