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
	public enum ContentType: String {
		case applicationJSON = "application/json"
	}

	public enum HTTPMethod: String {
		case delete
		case get
		case post
		case put
	}

	public init(
		method:          HTTPMethod,
		bearerToken:     String?         =  nil,
		header:         [String: String] = [:],
		url:             URL,
		body:            Encodable?      =  nil,
		encoder:         JSONEncoder     =  JSONEncoder(),
		cachePolicy:     CachePolicy     = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval    =  60
	) throws {
		var mutableHeader = header
		if let bearerToken {
			mutableHeader.updateValue("Bearer \(bearerToken)", forKey: "Authorization")
		}
		try self.init(
			method:          method,
			header:          mutableHeader,
			url:             url,
			body:            body != nil ?  encoder.encode(body!) : nil,
			contentType:     body != nil ? .applicationJSON       : nil,
			cachePolicy:     cachePolicy,
			timeoutInterval: timeoutInterval
		)
	}

	public init(
		method:          HTTPMethod,
		header:         [String: String] = [:],
		url:             URL,
		body:            Data?           =  nil,
		contentType:     ContentType?    =  nil,
		cachePolicy:     CachePolicy     = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval    =  60
	) {
		self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
		httpMethod = method.rawValue
		for (field, value) in header {
			setValue(value, forHTTPHeaderField: field)
		}
		if let contentType {
			setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
		}
		httpBody = body
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

	@available(*, deprecated, message: "use httpData(from:delegate:) instead.", renamed: "httpData(from:delegate:)")
	public func httpDecode<T: Decodable>(
		_    type: T.Type,
		from url:  URL,
		decoder:   JSONDecoder             = JSONDecoder(),
		delegate:  URLSessionTaskDelegate? = nil
	) async throws -> (T, HTTPURLResponse) {
		let (data, response) = try await httpData(from: url, delegate: delegate)
		return (try decoder.decode(type, from: data), response)
	}

	@available(*, deprecated, message: "use httpData(for:delegate:) instead.", renamed: "httpData(for:delegate:)")
	public func httpDecode<T: Decodable>(
		_   type:    T.Type,
		for request: URLRequest,
		decoder:     JSONDecoder             = JSONDecoder(),
		delegate:    URLSessionTaskDelegate? = nil
	) async throws -> (T, HTTPURLResponse) {
		let (data, response) = try await httpData(for: request, delegate: delegate)
		return (try decoder.decode(type, from: data), response)
	}
}
