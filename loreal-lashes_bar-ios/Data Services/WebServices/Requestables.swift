//
//  Requestables.swift
//  NYXPaletteBuilder
//
//  Created by Rob Nadin on 24/05/2016.
//  Copyright © 2016 Macoscope. All rights reserved.
//

import Foundation

enum HTTPMethod : String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

enum MediaType : String {
    case JSON = "application/json"
}

enum RequestHeader : String {
    case Authorization = "Authorization"
    case ContentType = "Content-Type"
}

protocol Requestable {}
protocol WebServiceRequest : Requestable {
    
    associatedtype Response : WebServiceResponse
    associatedtype Task = NSURLSessionDataTask
    
    var URL: NSURL { get }
    var method: HTTPMethod { get }
    var includeAccessToken: Bool { get }
    var requestBody: AnyObject? { get }
    var acceptableStatusCodes: [HTTPStatusCode] { get }
    var taskIdentifier: String { get }
}

// Default parameters
extension WebServiceRequest {
    
    var method: HTTPMethod { return .GET }
    var includeAccessToken: Bool { return true }
    var requestBody: AnyObject? { return nil }
    var acceptableStatusCodes: [HTTPStatusCode] { return [.OK] }
    var taskIdentifier: String { return String(self.dynamicType) }
}

extension WebServiceRequest {
    
    private var requestDescription: String { return String(self.dynamicType) }
    
    private func createRequest() -> NSMutableURLRequest {
        let mutableRequest = NSMutableURLRequest(URL: URL)
        mutableRequest.HTTPMethod = method.rawValue
        mutableRequest.setValue(MediaType.JSON.rawValue, forHTTPHeaderField: RequestHeader.ContentType.rawValue)
        
        if let accessToken = NSUserDefaults.accessToken where includeAccessToken {
            mutableRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: RequestHeader.Authorization.rawValue)
        }
        
        if let obj = requestBody {
            mutableRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(obj, options: [])
        }
        
        return mutableRequest
    }
    
    func executeInSharedSession(dispatchQueue: dispatch_queue_t = dispatch_get_main_queue(),
                                completion: (WebServiceResult<Response> -> Void)? = nil) -> NSURLSessionDataTask {
        return executeInSession(NSURLSession.sharedSession(), dispatchQueue: dispatchQueue, completion: completion)
    }
    
    func executeInSession(session: NSURLSession,
                          dispatchQueue: dispatch_queue_t = dispatch_get_main_queue(),
                          completion: (WebServiceResult<Response> -> Void)? = nil) -> NSURLSessionDataTask {
        let completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void = { data, response, error in
            if let completion = completion {
                let result = self.parseResponse(data, response: response, error: error)
                dispatch_async(dispatchQueue) {
                    completion(result)
                }
            }
        }
        
        let request = createRequest()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard let statusCode = statusCodeFromResponse(response) where !(statusCode == .Unauthorized && self.includeAccessToken) else {
                refreshToken { result in
                    switch result {
                    case .Success:
                        let newRequest = self.createRequest()
                        let originalTask = session.dataTaskWithRequest(newRequest, completionHandler: completionHandler)
                        originalTask.resume()
                        
                    case .Failure:
                        completion?(.Failure(.Unauthorised))
                    }
                }
                return
            }
            
            completionHandler(data, response, error)
        }
        task.resume()
        return task
    }
    
    private func parseResponse(data: NSData?, response: NSURLResponse?, error: NSError?) -> WebServiceResult<Response> {
        if let error = error {
            switch error.code {
            case NSURLErrorNotConnectedToInternet:
                return .Failure(.NoInternetConnection)
                
            case NSURLErrorCancelled:
                return .Failure(.Cancelled)
                
            default:
                return .Failure(.NetworkingError(error))
            }
        }
        
        do {
            try validateResponseCode(response, data: data)
            
            guard let data = data else {
                return .Failure(.InvalidResponse)
            }
            
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String : AnyObject]
            let parsedResponse = try Response(json: json)
            
            return .Success(parsedResponse)
        } catch let requestError as RequestError {
            return .Failure(requestError)
        } catch {
            return .Failure(.InvalidResponse)
        }
    }
    
    private func validateResponseCode(response: NSURLResponse?, data: NSData?) throws {
        if let statusCode = statusCodeFromResponse(response) where !acceptableStatusCodes.contains(statusCode) {
            switch statusCode {
            case .Unauthorized:
                throw RequestError.Unauthorised
                
            default:
                try serverError(data)
                throw RequestError.BadResponse(statusCode: statusCode)
            }
        }
    }
    
    private func serverError(data: NSData?) throws {
        guard let data = data, json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String : AnyObject] else {
            return
        }
        
        if let error = try? ServerErrorData(json: json) {
            throw RequestError.ServerError(displayMessage: error.message)
        }
    }
}

private func statusCodeFromResponse(response: NSURLResponse?) -> HTTPStatusCode? {
    guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode else {
        return nil
    }
    return HTTPStatusCode(rawValue: statusCode)
}

private struct ServerErrorData {
    
    let message: String
    let errorcode: Int
    let documentation: String
    
    init(json: [String : AnyObject]) throws {
        message = try json.parse("message")
        errorcode = try json.parse("errorcode")
        documentation = try json.parse("documentation")
    }
}
