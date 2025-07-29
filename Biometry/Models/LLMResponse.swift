//
//  LLMResponse.swift
//  Biometry
//
//  Created by Nakatomi on 22/7/2025.
//

import Foundation

struct LLMResponse: Decodable {
    let textResponse: String
}

struct LLMQuery: Encodable {
    let query: String
}
