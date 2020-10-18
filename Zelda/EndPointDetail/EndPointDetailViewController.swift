//
//  EndPointDetailViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Charts
import Cocoa
import Combine

let testScanLogs = ScanLogInTimeSpan(
	today: Array(0..<SCAN_LOG_COUNT).map { i -> ScanLog in
		ScanLog(id: "", time: Date() - TimeInterval(60*5*i), duration: Double.random(in: 0.0..<50), errorCount: Int.random(in: 0..<3))
	},
	week: Array(0..<SCAN_LOG_COUNT).map { i -> ScanLog in
		ScanLog(id: "", time: Date() - TimeInterval(60*5*i), duration: Double.random(in: 0.0..<50), errorCount: Int.random(in: 0..<3))
	}
)

enum EndPointIndicator {
	case duration
	case error

	// MARK: Internal

	func getValue(log: ScanLog) -> Int {
		switch self {
		case .duration:
			return Int(log.duration)
		case .error:
			return log.errorCount
		}
	}
}

struct ScanLogInTimeSpan: Codable {
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
}

class EndPointDetailViewController: NSViewController {
	@IBOutlet var chartView: BarChartView!

	@Published var scanLogs: ScanLogInTimeSpan?
	@Published var span: ScanLogSpan = .today
	var indicator = EndPointIndicator.duration
	var cancellables = Set<AnyCancellable>()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		BackendAgent.default.listScanLogInSpan(endPoint: "5f741f9479f90d29afe9a867")
			.map { span -> ScanLogInTimeSpan? in
				span
			}
			.replaceError(with: nil)
			.assign(to: &$scanLogs)

		$scanLogs.combineLatest($span)
			.sink { [weak self] scanLogs, span in
				if let scanLogs = scanLogs {
					self?.setChartData(scanLogs, in: span)
				}
			}
			.store(in: &cancellables)
	}

	@IBAction func onSelectSpan(_ button: NSPopUpButton) {
		span = ScanLogSpan(id: button.selectedItem!.identifier!.rawValue)
	}
}
