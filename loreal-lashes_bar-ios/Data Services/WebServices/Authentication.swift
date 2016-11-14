//
//  Authentication.swift
//  NYXPaletteBuilder
//
//  Created by Rob Nadin on 24/05/2016.
//  Copyright © 2016 Macoscope. All rights reserved.
//

import Foundation

struct AuthenticationDetails {
    static let clientId = "104ua2lwrwsorlme6ge8nxxc"
    static let clientSecret = "1F8B9e2dedSRy38Jiuz2uLv0"
}

private let requestTokenURL = URL(string: "http://auth.exacttargetapis.com/v1/requestToken")!

/**
 *  Generates authentication token to be used in subsequent calls. Tokens are valid for 1 hour before having to be refreshed.
 */
struct RequestTokenRequest : WebServiceRequest {
    
    typealias Response = RequestTokenResponse
    
    let URL = requestTokenURL
    let method: HTTPMethod = .POST
    let includeAccessToken = false
    let clientId: String
    let clientSecret: String
    
    var requestBody: AnyObject? {
        return [
            "clientId" : clientId,
            "clientSecret" : clientSecret
        ] as AnyObject
    }
}

struct RequestTokenResponse : WebServiceResponse {
    
    let accessToken: String
    let expiresIn: Int
    
    init(json: [String : AnyObject]) throws {
        accessToken = try json.parse("accessToken")
        expiresIn = try json.parse("expiresIn")
    }
}

func refreshToken(_ completion: @escaping (APIRequestResult<String?>) -> Void) {
    let request = RequestTokenRequest(clientId: AuthenticationDetails.clientId, clientSecret: AuthenticationDetails.clientSecret)
    _ = request.executeInSharedSession() {
        if case let .success(response) = $0 {
            let accessToken = response.accessToken
            UserDefaults.accessToken = accessToken
            completion(.success(accessToken))
        } else {
            UserDefaults.accessToken = nil
            completion(.failure(RequestError.invalidResponse))
        }
    }
}
