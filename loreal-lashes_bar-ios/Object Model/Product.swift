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
            if let name = imagePath, let image = UIImage(named: name) { return image }
            return UIImage(named: defaultImageName)!
        }
    }
    
    /** Returns a product with the given identifier, or nil if none exists. */
    class func productWithIdentifier(_ identifier: String, context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> Product? {
        let fetch: NSFetchRequest<Product> = NSFetchRequest(entityName: Product.entityName)
        fetch.predicate = NSPredicate(format: "productID == %@", identifier)
        fetch.fetchLimit = 1
        
        let results = try? context.fetch(fetch)
        return results?.first
    }
    
    /** Returns an array of products whose identifiers appear in the passed list. */
    class func productsWithIdentifiers(_ identifiers: [String], context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> [Product] {
        let fetch: NSFetchRequest<Product> = NSFetchRequest(entityName: Product.entityName)
        fetch.predicate = NSPredicate(format: "%@ CONTAINS productID", identifiers)
        let results = try? context.fetch(fetch)
        return results ?? []
    }
    
    func configure(_ json: JSON) throws {
        name = try json["name"].string.unwrap("Product Name")
        productID = try json["product_id"].string.unwrap("Product ID")
        imagePath = json["image"].string // No need to unwrap, this can be nil
    }
    
}
