//
//  NetworkingExtensions.swift
//  Networking Extensions
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation

#if false
public struct HTTPErrorResponse: Decodable {
	public let error:  Bool
	public let reason: String
}
#endif

// MARK: -

extension HTTPURLResponse {
	public var isSuccess: Bool { 200 ..< 300 ~= statusCode }
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

// MARK: -

extension URLSession {
	public func httpData(from url: URL) async throws -> (Data, HTTPURLResponse) {
		let (data, urlResponse) = try await data(from: url)
		guard let httpURLResponse = urlResponse as? HTTPURLResponse
		else { throw URLError(.badServerResponse) }
		return (data, httpURLResponse)
	}

	public func httpData(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		let (data, urlResponse) = try await data(for: request)
		guard let httpURLResponse = urlResponse as? HTTPURLResponse
		else { throw URLError(.badServerResponse) }
		return (data, httpURLResponse)
	}
}
