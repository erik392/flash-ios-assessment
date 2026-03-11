//
//  NetworkManager.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/10.
//

import Foundation

final class NetworkManager {

    func fetchRequest<T: Decodable>(url: URL?,
                                    headers: [String: String] = [:]) async throws -> T {
        guard let endpointUrl = url else { throw CustomError.invalidUrl }
        
        var request = URLRequest(url: endpointUrl)
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return try await callRequest(with: request)
    }

    private func callRequest<T: Decodable>(with request: URLRequest) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: request)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(jsonString)")
            }
            throw CustomError.parsingError
        }
    }
}

enum CustomError: String, Error {

    case invalidResponse
    case invalidRequest
    case invalidUrl
    case invalidData
    case internalError
    case parsingError
}
