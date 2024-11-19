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
		case delete
		case get
		case post
		case put
	}

#if true
	public init(
		method:          HTTPMethod,
		header:         [String: String] = [:],
		url:             URL,
		body:            Data?           =  nil,
		encoder:         JSONEncoder     =  JSONEncoder(),
		cachePolicy:     CachePolicy     = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval    =  60
	) throws {
		self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
		httpMethod = method.rawValue
		for (field, value) in header {
			setValue(value, forHTTPHeaderField: field)
		}
		if let body {
			setValue(String(body.count), forHTTPHeaderField: "Content-Length")
			setValue("application/json", forHTTPHeaderField: "Content-Type")
			httpBody = body
		}
	}

	public init(
		method:          HTTPMethod,
		bearerToken:     String?      =  nil,
		url:             URL,
		body:            Encodable?   =  nil,
		encoder:         JSONEncoder  =  JSONEncoder(),
		cachePolicy:     CachePolicy  = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval =  60
	) throws {
		var header: [String: String] = [:]
		if let bearerToken {
			header.updateValue("Bearer \(bearerToken)", forKey: "Authorization")
		}
		try self.init(
			method:          method,
			header:          header,
			url:             url,
			body:            body != nil ? encoder.encode(body!) : nil,
			encoder:         encoder,
			cachePolicy:     cachePolicy,
			timeoutInterval: timeoutInterval
		)
	}
#else
	public init(
		method:          HTTPMethod,
		header:         [String: String] = [:],
		url:             URL,
		body:            Data?           =  nil,
		contentType:     String?         =  nil,
		cachePolicy:     CachePolicy     = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval    =  60
	) {
		self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
		httpMethod = method.rawValue
		for (field, value) in header {
			setValue(value, forHTTPHeaderField: field)
		}
		if let body, let contentType {
			setValue(String(body.count), forHTTPHeaderField: "Content-Length")
			setValue(contentType,        forHTTPHeaderField: "Content-Type")
			httpBody = body
		}
	}

	public init(
		method:          HTTPMethod,
		bearerToken:     String?      =  nil,
		url:             URL,
		body:            Data?        =  nil,
		contentType:     String?      =  nil,
		cachePolicy:     CachePolicy  = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval =  60
	) {
		var header: [String: String] = [:]
		if let bearerToken {
			header.updateValue("Bearer \(bearerToken)", forKey: "Authorization")
		}
		self.init(
			method:          method,
			header:          header,
			url:             url,
			body:            body,
			contentType:     contentType,
			cachePolicy:     cachePolicy,
			timeoutInterval: timeoutInterval
		)
	}
#endif
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

	@available(*, deprecated, message: "Use httpData instead.")
	public func httpDecode<T: Decodable>(
		_    type: T.Type,
		from url:  URL,
		decoder:   JSONDecoder             = JSONDecoder(),
		delegate:  URLSessionTaskDelegate? = nil
	) async throws -> (T, HTTPURLResponse) {
		let (data, response) = try await httpData(from: url, delegate: delegate)
		return (try decoder.decode(type, from: data), response)
	}

	@available(*, deprecated, message: "Use httpData instead.")
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
