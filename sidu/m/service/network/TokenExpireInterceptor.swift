//
//  TokenExpireInterceptor.swift
//  sidu
//
//  Created by Armstrong Liu on 06/09/2024.
//

import Foundation
import Combine

class TokenExpireInterceptor: URLProtocol {
    static var routeCoordinator: RouteCoordinator?
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Only for http and https
        if request.url?.scheme == "http" || request.url?.scheme == "https" {
            return true
        }
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // 1) Copy the original request to mutable request. Because it is easy to modify the request. e.g. add headers or redirect the request
        if let copiedRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
            // 2) Make the request with the copied request (if some modifications are made)
            let task = URLSession.shared.dataTask(with: copiedRequest as URLRequest) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 401 {
                        // 3) 401 Unauthorized means the token expired, back to login page
                        self.handleUnauthorizedError()
                        // Stop loading and return
                        self.client?.urlProtocolDidFinishLoading(self)
                        return
                    }
                }
                // 4) Normal return data
                if let data = data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                // 5) Normal response
                if let response = response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                // 6) Normal handle error
                if let error = error {
                    self.client?.urlProtocol(self, didFailWithError: error)
                }
                // 7) Finish loading
                self.client?.urlProtocolDidFinishLoading(self)
            }
            task.resume()
        }
    }
    
    override func stopLoading() {
        // Cancel the request if needed
    }
    
    func handleUnauthorizedError() {
        // Handle token expired error with PassthroughSubject to notify the RouteCoordinator
        DispatchQueue.main.async {
            TokenExpireInterceptor.routeCoordinator?.tokenExpiredSubject.send()
        }
    }
}
