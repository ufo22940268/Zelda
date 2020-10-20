//
//  EndPointIndicator.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/20.
//

import Charts
import Cocoa
import Foundation

enum EndPointIndicator: String, CaseIterable {
	case duration
	case issue

	// MARK: Internal

	class DurationValueFormatter: IAxisValueFormatter {
		func stringForValue(_ value: Double, axis: AxisBase?) -> String {
			"\(Int(value)) ms"
		}
	}

	var maxY: Int {
		switch self {
		case .duration:
			return 100
		case .issue:
			return 10
		}
	}

	var reservedY: Int {
		switch self {
		case .duration:
			return 20
		case .issue:
			return 5
		}
	}

	var valueFormatter: IAxisValueFormatter {
		switch self {
		case .duration:
			return DurationValueFormatter()
		case .issue:
			return DefaultAxisValueFormatter()
		}
	}
	
	var valueColumnName: String {
		switch self {
		case .duration:
			return "时长"
		case .issue:
			return "错误数"
		}
	}

	func getValue(log: ScanLog) -> Int {
		switch self {
		case .duration:
			return Int(log.duration * 1000)
		case .issue:
			return log.errorCount
		}
	}
}

extension EndPointIndicator {
	init(identifier: String) {
		self = Self.allCases.first { $0.rawValue == identifier }!
	}
}
