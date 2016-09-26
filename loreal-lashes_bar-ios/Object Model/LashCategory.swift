//
//  LashCategory.swift
//  loreal-lashes_bar-ios
//
//  Created by Igor Nakonetsnoi on 22/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class LashCategory: NSManagedObject {
    
    var defaultImageName: String { get { return "product_default" } }
    
    var image: UIImage {
        get {
            // TODO: when a web service is implemented, this will change (hence 'imagePath' rather than 'imageName')
            if let name = imagePath, image = UIImage(named: name) { return image }
            return UIImage(named: defaultImageName)!
        }
    }

    /** Returns all LashCategory objects in the correct order. */
    class func orderedCategories(context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> [LashCategory] {
        let fetch = NSFetchRequest(entityName: LashCategory.entityName)
        fetch.sortDescriptors = [NSSortDescriptor(key: "ordinal", ascending: true)]
        do { return (try context.executeFetchRequest(fetch) as? [LashCategory]) ?? [] }
        catch { return [] }
    }
    
    /** Returns all lashes belonging to the receiver, in the correct order. */
    func orderedLashes() -> [Lash] {
        guard let unorderedSet = lashes else { return [] }
        return unorderedSet.sort({ $0.0.ordinal < $0.1.ordinal })
    }

    /** Returns an array of categories whose names appear in the passed list. */
    class func categoriesWithNames(identifiers: [String], context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> [LashCategory] {
        let fetch = NSFetchRequest(entityName: LashCategory.entityName)
        fetch.predicate = NSPredicate(format: "%@ CONTAINS name", identifiers)
        guard let results = try? context.executeFetchRequest(fetch) as? [LashCategory] else { return [] }
        return results ?? []
    }
}

extension LashCategory: JSONConfigurable {
    
    func configure(json: JSON) throws {
        name = try json["name"].string.unwrap("Category Name")
        detail = try json["detail"].string.unwrap("Category Detail")
        imagePath = json["image"].string // No need to unwrap, this can be nil
    }
}