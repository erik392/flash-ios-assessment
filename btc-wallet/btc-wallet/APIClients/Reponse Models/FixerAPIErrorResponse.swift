//
//  FixerAPIErrorResponse.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/11.
//

struct FixerAPIErrorResponse: Decodable {
    let success: Bool
    let error: ErrorDetail
}

struct ErrorDetail: Decodable {
    let code: Int
    let type: String
    let info: String
    let message: String?
}
