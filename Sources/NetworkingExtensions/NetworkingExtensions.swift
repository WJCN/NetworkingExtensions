//
//  NetworkingExtensions.swift
//  Networking Extensions
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation

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
		method:          HTTPMethod,
		url:             URL,
		bearerToken:     String?      = nil,
		body:            Data?        = nil,
		cachePolicy:     CachePolicy  = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval = 60
	) {
		self.init(
			url:             url,
			cachePolicy:     cachePolicy,
			timeoutInterval: timeoutInterval
		)
		self.httpMethod = method.rawValue
		if let bearerToken {
			self.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
		}
		if let body {
			self.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
			self.setValue("Application/JSON", forHTTPHeaderField: "Content-Type")
			self.httpBody = body
		}
	}

	public init(
		method:          HTTPMethod,
		url:             URL,
		bearerToken:     String?      = nil,
		body:            Encodable?   = nil,
		encoder:         JSONEncoder  = JSONEncoder(),
		cachePolicy:     CachePolicy  = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval = 60
	) throws {
		var data: Data?
		if let body {
			data = try encoder.encode(body)
		}
		self.init(
			method:          method,
			url:             url,
			bearerToken:     bearerToken,
			body:            data,
			cachePolicy:     cachePolicy,
			timeoutInterval: timeoutInterval
		)
	}
}

// MARK: -

extension URLSession {
	public func httpData(
		from url: URL,
		delegate: URLSessionTaskDelegate? = nil
	) async throws -> (Data, HTTPURLResponse) {
		let (data, urlResponse) = try await data(from: url, delegate: delegate)
		guard let httpURLResponse = urlResponse as? HTTPURLResponse
		else { throw URLError(.badServerResponse) }
		return (data, httpURLResponse)
	}

	public func httpData(
		for request: URLRequest,
		delegate:    URLSessionTaskDelegate? = nil
	) async throws -> (Data, HTTPURLResponse) {
		let (data, urlResponse) = try await data(for: request, delegate: delegate)
		guard let httpURLResponse = urlResponse as? HTTPURLResponse
		else { throw URLError(.badServerResponse) }
		return (data, httpURLResponse)
	}

	public func httpDecode<T: Decodable>(
		_    type:    T.Type,
		from url:     URL,
		with decoder: JSONDecoder             = JSONDecoder(),
		delegate:     URLSessionTaskDelegate? = nil
	) async throws -> (T, HTTPURLResponse) {
		let (data, response) = try await httpData(from: url, delegate: delegate)
		return (try decoder.decode(type, from: data), response)
	}

	public func httpDecode<T: Decodable>(
		_    type:    T.Type,
		for  request: URLRequest,
		with decoder: JSONDecoder             = JSONDecoder(),
		delegate:     URLSessionTaskDelegate? = nil
	) async throws -> (T, HTTPURLResponse) {
		let (data, response) = try await httpData(for: request, delegate: delegate)
		return (try decoder.decode(type, from: data), response)
	}
}
