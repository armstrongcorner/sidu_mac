//
//  ApiClient.swift
//  sidu
//
//  Created by Armstrong Liu on 01/03/2025.
//

import Foundation

enum ApiError: Error {
    case invalidUrl(String)
    case encodingError(Error)
    case decodingError(Error)
    case timeout
    case statusCode(Int)
    case invalidResponse
    case unknown
}

protocol ApiClientProtocol: Sendable {
    func get<T: Decodable & Sendable>(urlString: String, headers: [String : String]?, responseType: T.Type) async throws -> T?
    func post<T: Decodable & Sendable, R: Encodable & Sendable>(urlString: String, headers: [String : String]?, body: R?, responseType: T.Type) async throws -> T?
}

final class ApiClient: ApiClientProtocol {
    
    private func getHeaders() -> [String : String] {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-app-os": "macos",
            "x-app-version": appVersion,
        ]

        /*
         You can also add auth token here like:
         headers["Authorization"] = "Bearer \(token)"
         */
        
        return headers
    }
    
    private func customizedHeaders(_ headers: [String : String]?) -> [String : String] {
        var customizedHeaders = getHeaders()
        customizedHeaders.merge(headers ?? [:]) { (_, new) in new }
        return customizedHeaders
    }
    
    private func decodeData<T: Decodable & Sendable>(_ data: Data, responseType: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            throw ApiError.decodingError(error)
        }
    }

    private func performRequest<T: Decodable & Sendable>(
        urlString: String,
        method: String,
        headers: [String : String]? = nil,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T? {
        guard let url = URL(string: urlString) else {
            throw ApiError.invalidUrl(urlString)
        }
        
        var request = URLRequest(url: url)
        // Set http method
        request.httpMethod = method
        
        // Set new headers otherwise use the default
        let newHeaders = customizedHeaders(headers)
        newHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set http body
        if let body = body {
            request.httpBody = body
        }
        
        // Make the call
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // No response
            guard let response = response as? HTTPURLResponse else {
                throw ApiError.invalidResponse
            }
            // Invalid http code
            guard (200...299).contains(response.statusCode) else {
                throw ApiError.statusCode(response.statusCode)
            }
            
            return try decodeData(data, responseType: responseType)
        } catch {
            throw error
        }
    }
        
    func get<T: Decodable & Sendable>(
        urlString: String,
        headers: [String : String]? = [:],
        responseType: T.Type
    ) async throws -> T? {
        return try await performRequest(
            urlString: urlString,
            method: "GET",
            headers: headers,
            responseType: responseType
        )
    }
    
    func post<T: Decodable & Sendable, R: Encodable & Sendable>(
        urlString: String,
        headers: [String : String]? = [:],
        body: R? = nil,
        responseType: T.Type
    ) async throws -> T? {
        // Encode the reqest body to Data
        var bodyData: Data?
        
        if let body = body {
            do {
                bodyData = try JSONEncoder().encode(body)
            } catch {
                throw ApiError.encodingError(error)
            }
        }
        
        return try await performRequest(
            urlString: urlString,
            method: "POST",
            headers: headers,
            body: bodyData,
            responseType: responseType
        )
    }
}

