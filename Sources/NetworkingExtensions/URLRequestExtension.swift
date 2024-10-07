//
//  URLRequestExtension.swift
//  NetworkingExtensions
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation

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

	public init<T: Encodable>(
		method:      HTTPMethod,
		url:         URL,
		bearerToken: String?      = nil,
		body:        T?           = nil,
		encoder:     JSONEncoder? = nil
	) throws {
		self.init(url: url)
		self.httpMethod = method.rawValue
		if let bearerToken {
			self.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
		}
		if let body {
			self.setValue("application/json", forHTTPHeaderField: "Content-Type")
			self.httpBody = try (encoder ?? JSONEncoder()).encode(body)
		}
	}
}
