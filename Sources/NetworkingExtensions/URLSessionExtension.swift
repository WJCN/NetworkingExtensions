//
//  URLSessionExtension.swift
//  NetworkingExtensions
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation

extension URLSession {
	public func receive<T: Decodable>(
		_    type: T.Type,
		from url:  URL,
		delegate:  URLSessionTaskDelegate? = nil
	) async throws -> (result: T, response: URLResponse) {
		let (data, response) = try await data(from: url, delegate: delegate)
		return try (JSONDecoder().decode(T.self, from: data), response)
	}

	public func receive<T: Decodable>(
		_   type:    T.Type,
		for request: URLRequest,
		delegate:    URLSessionTaskDelegate? = nil
	) async throws -> (result: T, response: URLResponse) {
		let (data, response) = try await data(for: request, delegate: delegate)
		return try (JSONDecoder().decode(T.self, from: data), response)
	}
}
