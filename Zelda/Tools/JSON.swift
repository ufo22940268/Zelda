//
//  JSON.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/18.
//

import Foundation
import SwiftyJSON

extension JSONDecoder {
	static var backendDecoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
		return decoder
	}
}

struct JSONFragment {
	var text: String
	var hightlight = false
}

extension DateFormatter {
	static let iso8601Full: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
}

extension String {
	var jsonPrettify: String? {
		JSON(self).rawString(.utf8, options: [.prettyPrinted, .sortedKeys])
	}
}
