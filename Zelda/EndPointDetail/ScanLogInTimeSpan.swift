//
//  ScanLogInTimeSpan.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/20.
//

import Foundation

struct ScanLogInTimeSpan: Codable {
	// MARK: Internal

	var today: [ScanLog]
	var week: [ScanLog]

	subscript(span: ScanLogSpan) -> [ScanLog] {
		get {
			switch span {
			case .today:
				return today
			case .week:
				return week
			}
		}

		set {}
	}

	mutating func fillGap() {
		today = fillGap(step: 60*5, scanLogs: today)
		week = fillGap(step: 60*60*24, scanLogs: week)
	}

	// MARK: Private

	private mutating func fillGap(step: TimeInterval, scanLogs rawScanLogs: [ScanLog]) -> [ScanLog] {
		var newScanLogs = [ScanLog]()
		
		let scanLogs = rawScanLogs.sorted { $0.time < $1.time }
		let maxTime = scanLogs.last!.time
		for i in (0..<SCAN_LOG_COUNT).reversed() {
			let begin = maxTime - Double(i + 1)*step
			let end = maxTime - Double(i)*step
			if let log = scanLogs.first(where: { $0.time > begin && $0.time <= end }) {
				newScanLogs.append(log)
			} else {
				newScanLogs.append(ScanLog(time: end))
			}
		}
		return newScanLogs
	}
}

