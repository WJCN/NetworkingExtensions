//
//  URLRequestExtension.swift
//  NetworkingExtensions
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation

extension URLRequest {
	public enum Method: String {
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
		method httpMethod: Method,
		url:               URL,
		bearerToken:       String? =  nil,
		contentType:       String  = "application/json",
		httpBody:          Data?   =  nil
	) {
		self.init(url: url)
		self.httpMethod = httpMethod.rawValue
		if let bearerToken {
			self.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
		}
		if let httpBody {
			self.httpBody = httpBody
			self.setValue(contentType, forHTTPHeaderField: "Content-Type")
		}
	}
}
