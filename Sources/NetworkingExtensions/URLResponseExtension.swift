//
//  URLResponseExtension.swift
//  NetworkingExtensions
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation

extension URLResponse {
	public func check(throwing error: Error) throws {
		if let response = self as? HTTPURLResponse {
			guard (200 ..< 300).contains(response.statusCode)
			else { throw error }
		}
	}
}
