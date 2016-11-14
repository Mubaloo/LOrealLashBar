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
    class func orderedTechniques(_ context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> [Technique] {
        let fetch: NSFetchRequest<Technique> = NSFetchRequest(entityName: Technique.entityName)
        fetch.sortDescriptors = [NSSortDescriptor(key: "ordinal", ascending: true)]
        do { return (try context.fetch(fetch))}
        catch { return [] }
    }
    
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
    
}

extension Technique: JSONConfigurable {
    
    func configure(_ json: JSON) throws {
        name = try json["name"].string.unwrap("Technique Name")
        detail = try json["detail"].string.unwrap("Technique Detail")
        level = try json["level"].string.unwrap("Technique level")
        step1 = try json["step1"].string.unwrap("Technique step 1")
        step2 = try json["step2"].string.unwrap("Technique step 2")
        step3 = try json["step3"].string.unwrap("Technique step 3")
        
        remoteMediaPath = json["remote_path"].string
        videoId = json["remote_video_id"].string
        videoType = json["remote_video_type"].string
        localMediaPath = json["local_path"].string
        localMediaThumbPath = json["local_path_thumb"].string
        thumbPath = json["thumb_path"].string
    }
}
