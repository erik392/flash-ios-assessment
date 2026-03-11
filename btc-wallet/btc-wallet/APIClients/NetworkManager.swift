//
//  NetworkManager.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/10.
//

import Foundation

final class NetworkManager {

    func fetchRequest<T: Decodable, E: Decodable>(
        url: URL?,
        headers: [String: String] = [:],
        errorType: E.Type
    ) async throws -> T {
        guard let endpointUrl = url else { throw CustomError.invalidUrl }

        var request = URLRequest(url: endpointUrl)
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return try await callRequest(with: request, errorType: errorType)
    }

    private func callRequest<T: Decodable, E: Decodable>(
        with request: URLRequest,
        errorType: E.Type
    ) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)

        try checkHTTPStatus(data: data, response: response, errorType: errorType)

        return try decode(T.self, from: data, errorType: errorType)
    }

    private func checkHTTPStatus<E: Decodable>(
        data: Data,
        response: URLResponse,
        errorType: E.Type
    ) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        if !(200...299).contains(httpResponse.statusCode) {
            // Try decoding the API-specific error
            if let apiError = try? JSONDecoder().decode(E.self, from: data) {
                throw CustomError.apiError(apiError)
            } else {
                throw CustomError.unknownStatusCode(httpResponse.statusCode)
            }
        }
    }

    private func decode<T: Decodable, E: Decodable>(
        _ type: T.Type,
        from data: Data,
        errorType: E.Type
    ) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if let apiError = try? JSONDecoder().decode(E.self, from: data) {
                throw CustomError.apiError(apiError)
            }
            throw CustomError.parsingError
        }
    }
}

enum CustomError: Error {
    case invalidUrl
    case parsingError
    case apiError(Any)
    case unknownStatusCode(Int)
}
