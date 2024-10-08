//
//  NetworkingExtensions.swift
//  Axis
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation

extension JSONDecoder {
	@inlinable
	public func decode<T: Decodable>(
		_    type:    T.Type,
		from request: URLRequest,
		session:      URLSession = .shared
	) async throws -> (result: T, response: URLResponse) {
		let (data, response) = try await session.data(for: request)
		return try (decode(T.self, from: data), response)
	}
}

// MARK: -

extension URLRequest {
	public enum HTTPMethod: String {
		case connect
		case delete
		case head
		case get
		case options
		case patch
		case post
		case put
		case trace
	}

	public init(
		method:      HTTPMethod,
		url:         URL,
		bearerToken: String? = nil,
		body:        Data?   = nil
	) {
		self.init(url: url)
		self.httpMethod = method.rawValue
		if let bearerToken {
			self.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
		}
		if let body {
			self.setValue("application/json", forHTTPHeaderField: "Content-Type")
			self.httpBody = body
		}
	}
}
