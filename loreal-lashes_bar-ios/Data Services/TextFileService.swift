//
//  TextFileService.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TextFileService: BaseService {
    
    func fetchJSON(completion: BaseServiceFetchResponse) {
        guard let url = NSBundle.mainBundle().URLForResource("data", withExtension: "json"),
            data = NSData(contentsOfURL: url) else {
            completion(json: nil, error: DataServiceError.NoContentError)
            return
        }
        
        let json = JSON(data: data)
        completion(json: json, error: nil)
    }
    
}