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
    
    func fetchJSON(_ completion: BaseServiceFetchResponse) {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
            completion(nil, DataServiceError.noContentError)
            return
        }
        
        let json = JSON(data: data)
        completion(json, nil)
    }
    
}
