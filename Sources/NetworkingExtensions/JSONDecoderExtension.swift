//
//  JSONDecoderExtension.swift
//  NetworkingExtensions
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation

extension JSONDecoder {
	@inlinable
	public func decode<T: Decodable>(
		_    type:    T.Type,
		from request: URLRequest
	) async throws -> (result: T, response: URLResponse) {
		let (data, response) = try await URLSession.shared.data(for: request)
		return try (decode(T.self, from: data), response)
	}
}
