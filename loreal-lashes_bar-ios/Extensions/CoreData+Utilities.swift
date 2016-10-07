//
//  CoreData+Utilities.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

extension Optional {
    
    /**
     Handy function that can be used to convert an 'unexpected nil' exception to a handleable
     Swift error type. The optional `itemName` is returned as part of the error message allowing
     debuggers to note which object failed to unwrap accurately. Primarily used when parsing
     web service response JSON.
     */
    func unwrap(_ itemName: String? = nil) throws -> Wrapped {
        switch self {
        case .some(let value) :
            return value
        default :
            throw UnwrapError.noContentError(itemName: itemName ?? "Unknown")
        }
    }
    
}

extension NSManagedObject {
    
    /**
     The managed object's entity name within the object model.
     */
    final class var entityName: String {
        get {
            let original = NSStringFromClass(self)
            let parts = original.components(separatedBy: ".")
            return parts.last!
        }
    }
    
    /**
     Creates and returns a new instance of the relevant type. This function should be called
     from the appropriate `NSManagedObject` subclass. If JSON is supplied and the managed object
     in question supports the JSONConfigurable protocol, it will be returned ready-configured.
     */
    class func new<T: NSManagedObject>(_ json: JSON? = nil, context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) throws -> T {
        let new = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        if let json = json, let configurable = new as? JSONConfigurable {
            try configurable.configure(json)
        }
        return new as! T
    }
    
}

extension NSManagedObjectContext {
    
    /**
     A handy function that iterates over all entities in the object model for this context,
     outputting to the console the quantity that it currently contains and the name of that
     object in an easy-to-read format. Useful for debugging.
     */
    func catalogueAllManagedObjects() {
        if let model = self.persistentStoreCoordinator?.managedObjectModel {
            print("")
            print("Core Data Entity Catalogue")
            print("--------------------------")
            let allEntities = model.entitiesByName
            for (key, _) in allEntities {
                let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:key)
                do {
                    let count = try self.count(for: fetch)
                     print("\(count): \(key)")
                } catch {
                    print(error)
                }
            }
            print("--------------------------")
            print("")
        } else {
            print("Cannot catalogue a context with no associated object model.")
        }
    }
    
}
