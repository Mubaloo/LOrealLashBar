//
//  Product.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 02/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON


class Product: NSManagedObject, JSONConfigurable {

    var defaultImageName: String { get { return "WL01THUMB" } }
    
    var image: UIImage {
        get {
            // TODO: when a web service is implemented, this will change (hence 'imagePath' rather than 'imageName')
            if let name = imagePath, image = UIImage(named: name) { return image }
            return UIImage(named: defaultImageName)!
        }
    }
    
    /** Returns a product with the given identifier, or nil if none exists. */
    class func productWithIdentifier(identifier: String, context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> Product? {
        let fetch = NSFetchRequest(entityName: Product.entityName)
        fetch.predicate = NSPredicate(format: "productID == %@", identifier)
        fetch.fetchLimit = 1
        
        guard let results = try? context.executeFetchRequest(fetch) as? [Product] else { return nil }
        return results?.first
    }
    
    /** Returns an array of products whose identifiers appear in the passed list. */
    class func productsWithIdentifiers(identifiers: [String], context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> [Product] {
        let fetch = NSFetchRequest(entityName: Product.entityName)
        fetch.predicate = NSPredicate(format: "%@ CONTAINS productID", identifiers)
        guard let results = try? context.executeFetchRequest(fetch) as? [Product] else { return [] }
        return results ?? []
    }
    
    func configure(json: JSON) throws {
        name = try json["name"].string.unwrap("Product Name")
        productID = try json["product_id"].string.unwrap("Product ID")
        imagePath = json["image"].string // No need to unwrap, this can be nil
    }
    
}