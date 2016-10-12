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
    
    var remoteMediaURL: String? {
        get {
            if let path = remoteMediaPath {
                return path
            }
            return nil
        }
    }
    
    var remoteVideoId: String? {
        get {
            if  let id = videoId {
                return id
            }
            return nil
        }
    }
    
    var remoteVideoType: String? {
        get {
            if  let type = videoType {
                return type
            }
            return nil
        }
    }
    
    var localMediaURL: URL {
        get {
            if let path = localMediaPath {
                let components = path.components(separatedBy: ".")
                if components.count >= 2, let ext = components.last {
                    let name = components[0..<components.count-1].joined(separator: ".")
                    if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                        return url
                    }
                }
            }
            
            return Bundle.main.url(forResource: "default_movie", withExtension: "mov")!
        }
    }
    
    var localMediaThumbURL: URL {
        get {
            if let path = localMediaThumbPath {
                let components = path.components(separatedBy: ".")
                if components.count >= 2, let ext = components.last {
                    let name = components[0..<components.count-1].joined(separator: ".")
                    if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                        return url
                    }
                }
            }
            
            return Bundle.main.url(forResource: "default_movie", withExtension: "mov")!
        }
    }
    
    var thumbURL: URL {
        get {
            if let path = thumbPath {
                let components = path.components(separatedBy: ".")
                if components.count >= 2, let ext = components.last {
                    let name = components[0..<components.count-1].joined(separator: ".")
                    if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                        return url
                    }
                }
            }
            
            return Bundle.main.url(forResource: "default_thumb", withExtension: "png")!
        }
    }
    
    fileprivate var _thumbCache: UIImage?
    var thumbnail: UIImage {
        get {
            if let thumb = _thumbCache { return thumb }
            precache()
            return _thumbCache!
        }
    }
    
    func precache() {
        if let data = try? Data(contentsOf: thumbURL) {
            _thumbCache = UIImage(data: data)
        }
    }
    
    /** Returns a lash with the given identifying number, or nil if none exists with that number.  */
    class func lashWithNumber(_ number: Int16, context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> Lash? {
        let request: NSFetchRequest<Lash> = NSFetchRequest(entityName: self.entityName)
        request.predicate = NSPredicate(format: "number == %d", number)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if results.count == 0 { return nil }
            return results[0]
        } catch {
            return nil
        }
    }
    
    /** Returns a lash with the given name, or nil if none exists with that name.  */
    class func lashWithName(_ name: String, context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> Lash? {
        let request: NSFetchRequest<Lash> = NSFetchRequest(entityName: self.entityName)
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if results.count == 0 { return nil }
            return results[0]
        } catch {
            return nil
        }
    }
    
    override func configure(_ json: JSON) throws {
        try super.configure(json)
        number = try json["number"].int16.unwrap("Lash Number")
        detail = try json["detail"].string.unwrap("Lash Detail Text")
        hotTips = try json["hot_tip"].string.unwrap("Lash Alternative Uses")
        length = try json["length"].string.unwrap("Lash Length")
        
        ordinal = number // This may be necessary if lash number changes to a string
        
        remoteMediaPath = json["remote_path"].string
        videoId = json["remote_video_id"].string
        videoType = json["remote_video_type"].string
        localMediaPath = json["local_path"].string
        localMediaThumbPath = json["local_path_thumb"].string
        thumbPath = json["thumb_path"].string
        
        if let categoriesJSON = json["categories"].array {
            let identifiers = try categoriesJSON.map({ try $0.string.unwrap("Related Categories Relationship") })
            categories = Set(LashCategory.categoriesWithNames(identifiers))
        }
    
    }
}
