//
//  URLConverter.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/28.
//

import Foundation

typealias Params = [Param]

extension Params {
	var queryItems: [URLQueryItem] {
		self.map { URLQueryItem(name: $0.key, value: $0.value) }
	}
}

typealias URLQueryItems = [URLQueryItem]

extension URLQueryItems {
	var params: [Param] {
		self.map { Param(key: $0.name, value: $0.value ?? "") }
	}
}
