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

class EndPointDetailViewController: NSViewController {
	// MARK: Internal

	@IBOutlet var chartView: BarChartView!

	@IBOutlet var detailTableView: NSTableView!
	@Published var endPointId: String?
	var cancellables = Set<AnyCancellable>()

	@Published var scanLogsInSpan: ScanLogInTimeSpan?
	@Published var span: ScanLogSpan = .today

	var indicator = EndPointIndicator.duration {
		didSet {
			updateTableColumn()
		}
	}

	var scanLogs: [ScanLog] {
		if let scanLogsInSpan = scanLogsInSpan {
			return scanLogsInSpan[span]
		} else {
			return []
		}
	}

	var validScanLogs: [ScanLog] {
		switch indicator {
		case .duration:
			return scanLogs.filter { $0.duration > 0 }
		case .issue:
			return scanLogs.filter { $0.errorCount > 0 }
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		$endPointId
			.filter { $0 != nil && !$0!.isEmpty }
			.removeDuplicates()
			.flatMap { endPointId in
				BackendAgent.default.listScanLogInSpan(endPoint: endPointId!)
			}
			.map { span -> ScanLogInTimeSpan? in
				span
			}
			.replaceError(with: nil)
			.map { [weak self] (scanlogs: ScanLogInTimeSpan?) -> ScanLogInTimeSpan? in
				guard let scanlogs = scanlogs else { return nil }
				var newScanLogs = scanlogs
				self?.fillScanLogGap(&newScanLogs)
				return newScanLogs
			}
			.sink(receiveValue: { [weak self] scanLogsInSpan in
				self?.scanLogsInSpan = scanLogsInSpan
				self?.detailTableView.reloadData()
			})
			.store(in: &cancellables)

		$scanLogsInSpan.combineLatest($span)
			.sink { [weak self] scanLogs, span in
				if let scanLogs = scanLogs {
					self?.setChartData(scanLogs, in: span)
				}
			}
			.store(in: &cancellables)
	}

	func load(endPoint: String) {
		endPointId = endPoint
		updateTableColumn()
	}

	// MARK: Fileprivate

	fileprivate func updateTableColumn() {
		if let detailTableView = detailTableView {
			detailTableView.tableColumns[1].headerCell.stringValue = indicator.valueColumnName
		}
	}
}
