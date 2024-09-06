//
//  ApiClient.swift
//  sidu
//
//  Created by Armstrong Liu on 05/09/2024.
//

import Foundation

class ApiClient {
    static let shared = ApiClient()
    
    private init() {}
    
    // Get default headers
    func getHeaders() -> [String: String] {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let token = CacheUtil.shared.getAuthInfo()?.token ?? ""
        
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-app-os": "macos",
            "x-app-version": appVersion,
            "Authorization": "Bearer \(token)"
        ]
    }
    
    // Common http request method
    func sendRequest<T: Decodable>(url: URL,
                                   method: String,
                                   headers: [String: String] = [:],
                                   body: Data? = nil,
                                   responseType: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        // Set default headers
        getHeaders().forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        // Set custom headers
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(responseType, from: data)
        return decodedResponse
    }
    
    // GET
    func get<T: Decodable>(url: URL,
                           headers: [String: String] = [:],
                           body: Data? = nil,
                           responseType: T.Type) async throws -> T {
        return try await sendRequest(url: url, method: "GET", headers: headers, body: body, responseType: responseType)
    }
    
    // POST
    func post<T: Decodable>(url: URL,
                            headers: [String: String] = [:],
                            body: Data? = nil,
                            responseType: T.Type) async throws -> T {
        return try await sendRequest(url: url, method: "POST", headers: headers, body: body, responseType: responseType)
    }
    
    // PUT
    func put<T: Decodable>(url: URL,
                           headers: [String: String] = [:],
                           body: Data? = nil,
                           responseType: T.Type) async throws -> T {
        return try await sendRequest(url: url, method: "PUT", headers: headers, body: body, responseType: responseType)
    }
    
    // DETETE
    func delete<T: Decodable>(url: URL,
                              headers: [String: String] = [:],
                              body: Data? = nil,
                              responseType: T.Type) async throws -> T {
        return try await sendRequest(url: url, method: "DELETE", headers: headers, body: body, responseType: responseType)
    }
    
    // POST for upload binary file
    func uploadFile<T: Decodable>(url: URL,
                                  fileData: Data,
                                  fileName: String,
                                  mimeType: String? = nil,
                                  headers: [String: String] = [:],
                                  responseType: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        
        // Create multipart form body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        
        if let mimeType = mimeType {
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        } else {
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        }
        
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body

        // Set default headers
        getHeaders().forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        // Set custom headers
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        // Override content type with 'multipart/form-data'
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(responseType, from: data)
        return decodedResponse
    }
}
