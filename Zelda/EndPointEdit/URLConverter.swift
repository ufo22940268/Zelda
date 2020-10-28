//
//  URLConverter.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/28.
//

import Foundation

typealias Params = [Param]

extension Params {}

typealias URLQueryItems = [URLQueryItem]

extension URLQueryItems {
	var params: [Param] {
		self.map { Param(key: $0.name, value: $0.value ?? "") }
	}
}
