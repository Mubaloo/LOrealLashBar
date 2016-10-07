//
//  Responsables.swift
//  NYXPaletteBuilder
//
//  Created by Rob Nadin on 24/05/2016.
//  Copyright © 2016 Macoscope. All rights reserved.
//

import Foundation

enum RequestError: Error {
    
    case noInternetConnection
    
    /// There was an NSURLError
    case networkingError(NSError)
    
    /// The response returned a non-2xx status code, with no display message from server
    case badResponse(statusCode: HTTPStatusCode)
    
    /// The response returned a non-2xx status code, with display message from server
    case serverError(displayMessage: String)
    
    /// The response returned a 401 error
    case unauthorised
    
    /// There was an invalid response from the server
    case invalidResponse
    
    /// The web service request was cancelled - normally when another request of the same type is made.
    case cancelled
    
    case other(NSError)
}

extension RequestError : CustomStringConvertible {
    
    var description: String {
        switch self {
        case .networkingError(let error):
            return error.localizedDescription
            
        case .badResponse(let statusCode):
            return HTTPURLResponse.localizedString(forStatusCode: statusCode.rawValue)
            
        case .serverError(let displayMessage):
            return displayMessage
            
        case .unauthorised:
            return HTTPURLResponse.localizedString(forStatusCode: HTTPStatusCode.unauthorized.rawValue)
            
        case .invalidResponse:
            fallthrough
        case .cancelled:
            return NSLocalizedString("Cancelled", comment: "")
            
        case .other(let error):
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
    case success(R)
    case successNoData
    case failure(RequestError)
}

enum APIRequestResult<R> {
    case success(R)
    case failure(RequestError)
}

protocol JSONSubscriptType {}
extension String : JSONSubscriptType {}

extension Dictionary where Key : JSONSubscriptType {
    
    func parse<T>(_ path: Key) throws -> T {
        guard let value = self[path] as? T else {
            throw RequestError.invalidResponse
        }
        return value
    }
}
