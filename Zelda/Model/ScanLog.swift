//
//  ScanLog.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Foundation

typealias ObjectId = String

let SCAN_LOG_COUNT = 7

struct ScanLog: Identifiable {
	var id: ObjectId
	var url: String?
	var time: Date
	var duration: TimeInterval
	var errorCount: Int
	var endPointId: ObjectId
}

enum ScanLogSpan: String, CaseIterable {
	case today
	case week

	// MARK: Internal

	func indexes(last date: Date) -> [String] {
		switch self {
		case .today:
			let formatter = DateFormatter()
			formatter.dateFormat = .none
			formatter.timeStyle = .short
			return (0 ..< SCAN_LOG_COUNT).reversed().map { formatter.string(from: date - Double(60*5*$0)) }
		default:
			return []
		}
	}
	
	init(id: String) {
		self = Self.allCases.first { $0.rawValue == id }!
	}
}

typealias ScanLogInTimeSpan = [ScanLogSpan: [ScanLog]]
