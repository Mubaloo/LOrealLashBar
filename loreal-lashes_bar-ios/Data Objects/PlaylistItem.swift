//
//  PlaylistItem.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 01/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import CoreData

/**
 Playlist Items are those with associated videos. This protocol must be adopted for an
 item to be displayed in the Playlist screen as it includes properties to indicate if 
 it is currently a member of the playlist, the location of its video both remotely and
 locally, a thumbnail image and an ordinal to determine the order of appearance in the
 list. Note that adopting this protocol does not automatically make an object available
 on the Playlist screen, it merely ensures that the playlist screen can display it once
 it has been manually included there.
 */

protocol PlaylistItem {
    var name: String { get }
    var isInPlaylist: Bool { get set }
    var remoteMediaURL: URL? { get }
    var remoteVideoId: String? { get }
    var remoteVideoType: String? { get }
    var localMediaURL: URL { get }
    var localMediaThumbURL: URL { get }
    var thumbnail: UIImage { get }
    var ordinal: Int16 { get }
    
    /** Called before the playlist is displayed to allow the thumbnail image and any
     other necessary data to be loaded into memory. This keeps the performance of the
     playlist's collection view nice and crisp.
     */
    func precache()
}

extension PlaylistItem where Self: NSManagedObject {
    
    /**
     Generic function returning a list of all items of the receiving class that are in
     the current user's playlist.
     */
    static func playlist(_ context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> [Self] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Self.entityName)
        fetchRequest.predicate = NSPredicate(format: "inPlaylist == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "ordinal", ascending: true)]
        let results = try? context.fetch(fetchRequest)
        return results as? [Self] ?? []
    }
    
}
