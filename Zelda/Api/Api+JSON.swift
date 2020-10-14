//
//  Api+JSON.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/14.
//

import Foundation
import SwiftyJSON

extension JSON {
	func convertToPathMap() -> [String: String] {
		traverseJson(json: self)
	}

	private func traverseJson(json: JSON, path: [String] = []) -> [String: String] {
		var j: JSON = json
		if let ar = json.array, ar.count > 0 {
			j = ar[0]
		}

		if let dict = j.dictionary {
			let ar = dict.map { args in
				self.traverseJson(json: args.value, path: path + [args.key])
			}.reduce(into: [String: String]()) { (r, dict) in
				for (key, value) in dict {
					r[key] = value
				}
			}
			return ar
		}
		return [path.joined(separator: "."): json.stringValue]
	}
}
