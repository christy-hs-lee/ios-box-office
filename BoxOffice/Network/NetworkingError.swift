//
//  NetworkingError.swift
//  BoxOffice
//
//  Created by Christy, Hyemory on 2023/03/21.
//

enum NetworkingError: Error {
    case decodeFailed
    case dataNotFound
    case clientError
    case serverError
    case unknownError
    case invalidURL
    case transportError(Error)
}
