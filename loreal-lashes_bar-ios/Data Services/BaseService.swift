//
//  BaseService.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias PopulateDatabaseCompletion = (_ error: Error?)->()
typealias BaseServiceFetchResponse = ((_ json: JSON?, _ error: Error?) -> ())

/**
 Protocol representing a web service. Note that under usual circumstances, only the
 `fetchJSON` method needs to be implemented. Data is parsed from the JSON en masse
 using functions in the accompanying extension.
 */

protocol BaseService {
    func populateDatabase(_ completion: PopulateDatabaseCompletion)
    func fetchJSON(_ completion: BaseServiceFetchResponse)
    func parseJSON(_ json: JSON) throws
}

extension BaseService {
    
    internal func populateDatabase(_ completion: (Error?) -> ()) {
        fetchJSON({ json, error in
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let json = json else {
                completion(DataServiceError.noContentError)
                return
            }
            
            do {
                CoreDataStack.shared.purgeDatabase()
                try self.parseJSON(json)
                completion(nil)
            } catch let error {
                completion(error)
            }
            
        })
    }
    
    func parseJSON(_ json: JSON) throws {
        
        if let productJSON = json["products"].array {
            let products = try productJSON.map({
                try Product.new($0) as Product
            })
            print("\(products.count) products parsed")
        }
        
        guard let categoryJSON = json["categories"].array else {
            throw ParseError.invalidContent(itemName: "Lash Category List")
        }
        
        let categories = try categoryJSON.enumerated().map({
            let newCat = try LashCategory.new($0.1) as LashCategory
            newCat.ordinal = Int16($0.0)
        })
        print("\(categories.count) categories parsed")
        CoreDataStack.shared.saveContext()
        
        guard let lashesJSON = json["lashes"].array else {
            throw ParseError.invalidContent(itemName: "Lashes List")
        }
        
        let lashes = try lashesJSON.enumerated().map({
            let newLash = try Lash.new($0.1) as Lash
            newLash.ordinal = Int16($0.0)
        })

        
        print("\(lashes.count) lashes parsed")
        
        guard let techniqueJSON = json["techniques"].array else {
            throw ParseError.invalidContent(itemName: "Technique List")
        }
        
        let techniques = try techniqueJSON.enumerated().map({
            let newTechnique = try Technique.new($0.1) as Technique
            newTechnique.ordinal = Int16($0.0)
        })
        
         CoreDataStack.shared.saveContext()
        print("\(techniques.count) techniques parsed")
    }
    
}
