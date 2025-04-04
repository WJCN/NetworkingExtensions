//
//  NetworkingExtensions.swift
//  Networking Extensions
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation
import HTTPTypes

extension URLError {
	public init(_ statusCode: Int, userInfo: [String: Any] = [:]) {
		self.init(Code(rawValue: statusCode), userInfo: userInfo)
	}
}

// MARK: -

extension HTTPURLResponse {
	public var isSuccess: Bool { 200 ..< 300 ~= statusCode }

	public var localizedString: String {
		Self.localizedString(forStatusCode: statusCode)
	}
}

// MARK: -

extension URLRequest {
	// MARK: Functions

	public init(
		method:          HTTPRequest.Method,
		url:             URL,
		header:         [String: String] = [:],
		bearerToken:     String?         =  nil,
		encoder:         JSONEncoder     =  JSONEncoder(),
		body:           (any Encodable)? =  nil,
		cachePolicy:     CachePolicy     = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval    =  60
	) throws {
		try self.init(
			method:          method,
			url:             url,
			header:          header,
			bearerToken:     bearerToken,
			contentType:     body != nil ? "application/json"     : nil,
			body:            body != nil ?  encoder.encode(body!) : nil,
			cachePolicy:     cachePolicy,
			timeoutInterval: timeoutInterval
		)
	}

	public init(
		method:          HTTPRequest.Method,
		url:             URL,
		header:         [String: String] = [:],
		bearerToken:     String?         =  nil,
		contentType:     String?         =  nil,
		body:            Data?           =  nil,
		cachePolicy:     CachePolicy     = .useProtocolCachePolicy,
		timeoutInterval: TimeInterval    =  60
	) {
		self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
		httpMethod = method.description
		for (field, value) in header {
			setValue(value, forHTTPHeaderField: field)
		}
		if let bearerToken, !bearerToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			setValue("Bearer \(bearerToken)", forHTTPHeaderField: Self.authorization)
		}
		if let contentType, !contentType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			setValue(contentType, forHTTPHeaderField: Self.contentType)
		}
		httpBody = body
	}

	// MARK: - Private Computed Properties

	private static var authorization: String { HTTPField.Name.authorization.description }
	private static var contentType:   String { HTTPField.Name.contentType  .description }
}

// MARK: -

extension URLSession {
	// MARK: Functions

	public func httpData(
		from     url:   URL,
		delegate:      (any URLSessionTaskDelegate)? = nil,
		throwing error: any Error                    = URLError(.badServerResponse)
	) async throws -> (Data, HTTPURLResponse) {
		let (data, urlResponse) = try await data(from: url, delegate: delegate)
		guard let httpURLResponse = urlResponse as? HTTPURLResponse else { throw error }
		return (data, httpURLResponse)
	}

	public func httpData(
		for      request: URLRequest,
		delegate:        (any URLSessionTaskDelegate)? = nil,
		throwing error:   any Error                    = URLError(.badServerResponse)
	) async throws -> (Data, HTTPURLResponse) {
		let (data, urlResponse) = try await data(for: request, delegate: delegate)
		guard let httpURLResponse = urlResponse as? HTTPURLResponse else { throw error }
		return (data, httpURLResponse)
	}

	// MARK: - Deprecated Functions

	@available(*, deprecated, message: "use httpData(from:delegate:) instead.", renamed: "httpData(from:delegate:)")
	public func httpDecode<T: Decodable>(
		_    type: T.Type,
		from url:  URL,
		decoder:   JSONDecoder                  = JSONDecoder(),
		delegate: (any URLSessionTaskDelegate)? = nil
	) async throws -> (T, HTTPURLResponse) {
		let (data, response) = try await httpData(from: url, delegate: delegate)
		return (try decoder.decode(type, from: data), response)
	}

	@available(*, deprecated, message: "use httpData(for:delegate:) instead.", renamed: "httpData(for:delegate:)")
	public func httpDecode<T: Decodable>(
		_   type:    T.Type,
		for request: URLRequest,
		decoder:     JSONDecoder                  = JSONDecoder(),
		delegate:   (any URLSessionTaskDelegate)? = nil
	) async throws -> (T, HTTPURLResponse) {
		let (data, response) = try await httpData(for: request, delegate: delegate)
		return (try decoder.decode(type, from: data), response)
	}
}
