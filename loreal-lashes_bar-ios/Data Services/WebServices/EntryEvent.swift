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
    let videoURLs: [String]
    let eventDefinitionKey = "NYX_Lash_Bar-EntryEvent"
    let source = "Retail"
    
    var requestBody: [String:Any] {
        return [
            "ContactKey" : emailAddress,
            "EventDefinitionKey" : eventDefinitionKey,
            "EstablishContactKey" : false,
            "Data" : [
                "EmailAddress" : emailAddress,
                "Email_Perm_Status" : "Y",
                "Video_URLs" : videoURLs.joined(separator: "|"),
                "Source" : source
            ]
        ]
    }
}

struct EntryEventResponse : WebServiceResponse {
    
    let eventInstanceId: UUID?
    
    init(json: [String : AnyObject]) throws {
        let eventInstanceId: String = try json.parse("eventInstanceId")
        self.eventInstanceId = UUID(uuidString: eventInstanceId)
    }
}
