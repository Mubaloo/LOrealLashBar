//
//  EntryEvent.swift
//  NYXPaletteBuilder
//
//  Created by Rob Nadin on 24/05/2016.
//  Copyright © 2016 Macoscope. All rights reserved.
//

import Foundation

private let interactionEventsURL = URL(string: "http://www.exacttargetapis.com/interaction/v1/events")!

/**
 *  Enters subscriber into Palette Builder journey - currently only sends one email.
 */
struct EntryEventRequest : WebServiceRequest {
    
    typealias Response = EntryEventResponse
    
    let URL = interactionEventsURL
    let method: HTTPMethod = .POST
    let acceptableStatusCodes: [HTTPStatusCode] = [.created]
    
    let emailAddress: String
    let videoItems: [[String:String]]
    let emailStatus: Bool
    let sendDate: String
    let eventDefinitionKey = "NYX_BrushLash_EntryEvent"
    let source = "Retail-LashBar"
    
    var requestBody: AnyObject? {
        return [
            "ContactKey" : emailAddress,
            "EventDefinitionKey" : eventDefinitionKey,
            "EstablishContactKey" : true,
            "Email_Perm_Status" : emailStatus ? "Y" : "N",
            "Source" : source,
            "Data" : [
                "emailaddress" : emailAddress,
                "send_date" : sendDate,
                "VideoData" : convertedVideoItems(items: videoItems),
            ]
        ] as AnyObject
    }
    
    func convertedVideoItems(items: [[String:String]]) -> String {
        var finalString = "<root>"
        let stringArray = items.map{(dictionary: [String:String]) -> String in
            guard let url = dictionary["Landing_URL"], let id = dictionary["Video_Id"], let type = dictionary["Video_Type"] else {
                return ""
            }
            return "<Video ID='\(id)' Landing_URL='\(url)' Video_Type='\(type)'></Video>"
        }
        finalString.append(stringArray.joined(separator: ""))
        finalString.append("</root>")
        return finalString
    }
}

struct EntryEventResponse : WebServiceResponse {
    
    let eventInstanceId: UUID?
    
    init(json: [String : AnyObject]) throws {
        let eventInstanceId: String = try json.parse("eventInstanceId")
        self.eventInstanceId = UUID(uuidString: eventInstanceId)
    }
}
