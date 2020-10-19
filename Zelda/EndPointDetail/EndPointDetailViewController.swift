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

	class DurationValueFormatter: IAxisValueFormatter {
		func stringForValue(_ value: Double, axis: AxisBase?) -> String {
			"\(Int(value)) ms"
		}
	}

	var maxY: Int {
		switch self {
		case .duration:
			return 100
		case .error:
			return 10
		}
	}

	var reservedY: Int {
		switch self {
		case .duration:
			return 20
		case .error:
			return 5
		}
	}

	var valueFormatter: IAxisValueFormatter {
		switch self {
		case .duration:
			return DurationValueFormatter()
		default:
			fatalError()
		}
	}

	func getValue(log: ScanLog) -> Int {
		switch self {
		case .duration:
			return Int(log.duration*1000)
		case .error:
			return log.errorCount
		}
	}
}

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

	private mutating func fillGap(step: TimeInterval, scanLogs: [ScanLog]) -> [ScanLog] {
		var newScanLogs = [ScanLog]()
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

class EndPointDetailViewController: NSViewController, EndPointLoadable {
	@IBOutlet var chartView: BarChartView!

	@Published var scanLogs: ScanLogInTimeSpan?
	@Published var span: ScanLogSpan = .today
	@Published var endPointId: String?
	var indicator = EndPointIndicator.duration
	var cancellables = Set<AnyCancellable>()

	override func viewDidLoad() {
		super.viewDidLoad()
		$endPointId
			.filter { $0 != nil && !$0!.isEmpty }
			.flatMap { endPointId in
				BackendAgent.default.listScanLogInSpan(endPoint: endPointId!)
			}
			.map { span -> ScanLogInTimeSpan? in
				span
			}
			.replaceError(with: nil)
			.map { [weak self] scanlogs in
				guard let scanlogs = scanlogs else { return nil }
				var newScanLogs = scanlogs
				self?.fillScanLogGap(&newScanLogs)
				return newScanLogs
			}
			.assign(to: &$scanLogs)

		$scanLogs.combineLatest($span)
			.sink { [weak self] scanLogs, span in
				if let scanLogs = scanLogs {
					self?.setChartData(scanLogs, in: span)
				}
			}
			.store(in: &cancellables)
	}

	func fillScanLogGap(_ scanLogs: inout ScanLogInTimeSpan) {
		scanLogs.fillGap()
	}

	func load(endPoint: String) {
		endPointId = endPoint
	}

	func onSelectSpan(_ span: ScanLogSpan) {
		self.span = span
	}
}
