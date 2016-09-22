//
//  Responsables.swift
//  NYXPaletteBuilder
//
//  Created by Rob Nadin on 24/05/2016.
//  Copyright © 2016 Macoscope. All rights reserved.
//

import Foundation

enum RequestError: ErrorType {
    
    case NoInternetConnection
    
    /// There was an NSURLError
    case NetworkingError(NSError)
    
    /// The response returned a non-2xx status code, with no display message from server
    case BadResponse(statusCode: HTTPStatusCode)
    
    /// The response returned a non-2xx status code, with display message from server
    case ServerError(displayMessage: String)
    
    /// The response returned a 401 error
    case Unauthorised
    
    /// There was an invalid response from the server
    case InvalidResponse
    
    /// The web service request was cancelled - normally when another request of the same type is made.
    case Cancelled
    
    case Other(NSError)
}

extension RequestError : CustomStringConvertible {
    
    var description: String {
        switch self {
        case .NetworkingError(let error):
            return error.localizedDescription
            
        case .BadResponse(let statusCode):
            return NSHTTPURLResponse.localizedStringForStatusCode(statusCode.rawValue)
            
        case .ServerError(let displayMessage):
            return displayMessage
            
        case .Unauthorised:
            return NSHTTPURLResponse.localizedStringForStatusCode(HTTPStatusCode.Unauthorized.rawValue)
            
        case .InvalidResponse:
            fallthrough
        case .Cancelled:
            return NSLocalizedString("Cancelled", comment: "")
            
        case .Other(let error):
            return error.localizedDescription
            
        default:
            return "Unknown Error (Code=\((_code))"
        }
    }
}

protocol Responsable {}
protocol WebServiceResponse : Responsable {
    init(json: [String : AnyObject]) throws
}

enum WebServiceResult<R> {
    case Success(R)
    case SuccessNoData
    case Failure(RequestError)
}

enum APIRequestResult<R> {
    case Success(R)
    case Failure(RequestError)
}

protocol JSONSubscriptType {}
extension String : JSONSubscriptType {}

extension Dictionary where Key : JSONSubscriptType {
    
    func parse<T>(path: Key) throws -> T {
        guard let value = self[path] as? T else {
            throw RequestError.InvalidResponse
        }
        return value
    }
}
