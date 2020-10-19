//
//  ScanLog.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Foundation

typealias ObjectId = String

let SCAN_LOG_COUNT = 7

struct ScanLog: Identifiable, Codable {
	// MARK: Lifecycle

	internal init(id: ObjectId, url: String? = nil, time: Date, duration: TimeInterval, errorCount: Int) {
		self.id = id
		self.url = url
		self.time = time
		self.duration = duration
		self.errorCount = errorCount
	}

	init(time: Date) {
		self.time = time
		duration = 0
		errorCount = 0
		id = ""
	}

	// MARK: Internal

	var id: ObjectId
	var url: String?
	var time: Date
	var duration: TimeInterval
	var errorCount: Int
}

enum ScanLogSpan: String, CaseIterable {
	case today
	case week

	// MARK: Lifecycle

	init(id: String) {
		self = Self.allCases.first { $0.rawValue == id }!
	}

	// MARK: Internal

	var step: TimeInterval {
		switch self {
		case .today:
			return 60*5
		case .week:
			return 60*60*24
		}
	}

	func indexes(last date: Date) -> [String] {
		switch self {
		case .today:
			let formatter = DateFormatter()
			formatter.dateFormat = .none
			formatter.timeStyle = .short
			return (0 ..< SCAN_LOG_COUNT).reversed().map { formatter.string(from: date - step*Double($0)) }
		default:
			let formatter = DateFormatter()
			formatter.dateStyle = .short
			formatter.timeStyle = .none
			return (0 ..< SCAN_LOG_COUNT).reversed().map { formatter.string(from: date - step*Double($0)) }
		}
	}
}

extension TimeInterval {
	var formatDuration: String {
		"\(Int(self*1000)) ms"
	}
}
