//
//  ChatService.swift
//  sidu
//
//  Created by Armstrong Liu on 04/09/2024.
//

import Foundation

class ChatService {
    func chat(message: String) async throws -> ChatResponse? {
        var request = URLRequest(url: Endpoint.chat.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["message": message])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let chatResponse = try? JSONDecoder().decode(ChatResponse.self, from: data)
        return chatResponse
    }
}
