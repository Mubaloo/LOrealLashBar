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
    associatedtype Task = URLSessionDataTask
    
    var URL: Foundation.URL { get }
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
    var acceptableStatusCodes: [HTTPStatusCode] { return [.ok] }
    var taskIdentifier: String { return String(describing: type(of: self)) }
}

extension WebServiceRequest {
    
    fileprivate var requestDescription: String { return String(describing: type(of: self)) }
    
    fileprivate func createRequest() -> NSMutableURLRequest {
        let mutableRequest = NSMutableURLRequest(url: URL)
        mutableRequest.httpMethod = method.rawValue
        mutableRequest.setValue(MediaType.JSON.rawValue, forHTTPHeaderField: RequestHeader.ContentType.rawValue)
        
        if let accessToken = UserDefaults.accessToken , includeAccessToken {
            mutableRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: RequestHeader.Authorization.rawValue)
        }
        
        if let obj = requestBody {
            mutableRequest.httpBody = try! JSONSerialization.data(withJSONObject: obj, options: [])
        }
        
        return mutableRequest
    }
    
    func executeInSharedSession(_ dispatchQueue: DispatchQueue = DispatchQueue.main,
                                completion: ((WebServiceResult<Response>) -> Void)? = nil) -> URLSessionDataTask {
        return executeInSession(URLSession.shared, dispatchQueue: dispatchQueue, completion: completion)
    }
    
    func executeInSession(_ session: URLSession,
                          dispatchQueue: DispatchQueue = DispatchQueue.main,
                          completion: ((WebServiceResult<Response>) -> Void)? = nil) -> URLSessionDataTask {
        let completionHandler: (Data?, URLResponse?, NSError?) -> Void = { data, response, error in
            if let completion = completion {
                let result = self.parseResponse(data, response: response, error: error)
                dispatchQueue.async {
                    completion(result)
                }
            }
        }
        
        let request = createRequest() as URLRequest
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let statusCode = statusCodeFromResponse(response) , !(statusCode == .unauthorized && self.includeAccessToken) else {
                refreshToken { result in
                    switch result {
                    case .success:
                        let newRequest = self.createRequest() as URLRequest
                        let originalTask = session.dataTask(with: newRequest, completionHandler: completionHandler as! (Data?, URLResponse?, Error?) -> Void)
                        originalTask.resume()
                        
                    case .failure:
                        completion?(.failure(.unauthorised))
                    }
                }
                return
            }
            
            completionHandler(data, response, error as NSError?)
        }) 
        task.resume()
        return task
    }
    
    fileprivate func parseResponse(_ data: Data?, response: URLResponse?, error: NSError?) -> WebServiceResult<Response> {
        if let error = error {
            switch error.code {
            case NSURLErrorNotConnectedToInternet:
                return .failure(.noInternetConnection)
                
            case NSURLErrorCancelled:
                return .failure(.cancelled)
                
            default:
                return .failure(.networkingError(error))
            }
        }
        
        do {
            try validateResponseCode(response, data: data)
            
            guard let data = data else {
                return .failure(.invalidResponse)
            }
            
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : AnyObject]
            let parsedResponse = try Response(json: json)
            
            return .success(parsedResponse)
        } catch let requestError as RequestError {
            return .failure(requestError)
        } catch {
            return .failure(.invalidResponse)
        }
    }
    
    fileprivate func validateResponseCode(_ response: URLResponse?, data: Data?) throws {
        if let statusCode = statusCodeFromResponse(response) , !acceptableStatusCodes.contains(statusCode) {
            switch statusCode {
            case .unauthorized:
                throw RequestError.unauthorised
                
            default:
                try serverError(data)
                throw RequestError.badResponse(statusCode: statusCode)
            }
        }
    }
    
    fileprivate func serverError(_ data: Data?) throws {
        guard let data = data, let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : AnyObject] else {
            return
        }
        
        if let error = try? ServerErrorData(json: json) {
            throw RequestError.serverError(displayMessage: error.message)
        }
    }
}

private func statusCodeFromResponse(_ response: URLResponse?) -> HTTPStatusCode? {
    guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
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
