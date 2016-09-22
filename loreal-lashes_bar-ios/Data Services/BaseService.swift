//
//  BaseService.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias PopulateDatabaseCompletion = (error: ErrorType?)->()
typealias BaseServiceFetchResponse = ((json: JSON?, error: ErrorType?) -> ())

/**
 Protocol representing a web service. Note that under usual circumstances, only the
 `fetchJSON` method needs to be implemented. Data is parsed from the JSON en masse
 using functions in the accompanying extension.
 */

protocol BaseService {
    func populateDatabase(completion: PopulateDatabaseCompletion)
    func fetchJSON(completion: BaseServiceFetchResponse)
    func parseJSON(json: JSON) throws
}

extension BaseService {
    
    func populateDatabase(completion: PopulateDatabaseCompletion) {
        fetchJSON({ json, error in
            
            if let error = error {
                completion(error: error)
                return
            }
            
            guard let json = json else {
                completion(error: DataServiceError.NoContentError)
                return
            }
            
            do {
                CoreDataStack.shared.purgeDatabase()
                try self.parseJSON(json)
                completion(error: nil)
            } catch let error {
                completion(error: error)
            }
            
        })
    }
    
    func parseJSON(json: JSON) throws {
        
        if let productJSON = json["products"].array {
            let products = try productJSON.map({
                try Product.new($0) as Product
            })
            print("\(products.count) products parsed")
        }
        
        guard let categoryJSON = json["brushes"].array else {
            throw ParseError.InvalidContent(itemName: "Brush Category List")
        }
        
        let categories = try categoryJSON.enumerate().map({
            let newCat = try LashCategory.new($0.1) as LashCategory
            newCat.ordinal = Int16($0.0)
        })
        
        CoreDataStack.shared.saveContext()
        
        print("\(categories.count) categories parsed")
        
        guard let techniqueJSON = json["techniques"].array else {
            throw ParseError.InvalidContent(itemName: "Technique List")
        }
        
        let techniques = try techniqueJSON.enumerate().map({
            let newTechnique = try Technique.new($0.1) as Technique
            newTechnique.ordinal = Int16($0.0)
        })
        
        print("\(techniques.count) techniques parsed")
    }
    
}