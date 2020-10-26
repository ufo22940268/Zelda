//
//  ConfigStore.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/25.
//

import Foundation

var KEY_SCAN_LOG = "KEY_SCAN_LOG"

class ConfigStore {
	static let shared = ConfigStore()

	func set(range: ScanLogSpan) {
		UserDefaults.standard.set(range.rawValue, forKey: KEY_SCAN_LOG)
	}

	func getSpan() -> ScanLogSpan {
		if let value = UserDefaults.standard.string(forKey: KEY_SCAN_LOG) {
			return ScanLogSpan(rawValue: value) ?? .default
		} else {
			return .default
		}
	}
}
