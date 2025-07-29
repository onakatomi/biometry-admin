//
//  ApiService.swift
//  Biometry
//
//  Created by Nakatomi on 22/7/2025.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

struct ApiService {
    
    static let shared = ApiService()
    private init() {}
    
    func request<T: Decodable>(
        url: URL,
        method: HTTPMethod = .GET,
        body: Data? = nil
    ) async throws -> T {
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Setting headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Decoding the response data
        let decoder = JSONDecoder()
        let response = try decoder.decode(T.self, from: data)
        
        return response
    }
}
