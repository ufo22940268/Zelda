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

protocol IEndPointDetail {
	func load(endPoint: String)
}

class EndPointDetailViewController: NSViewController, IEndPointDetail {
	// MARK: Internal

	@IBOutlet var chartView: BarChartView!

	@IBOutlet var progressIndicator: NSProgressIndicator!
	@IBOutlet var detailTableView: NSTableView!
	@Published var endPointId: String?
	var cancellables = Set<AnyCancellable>()

	@IBOutlet var tableContainer: NSScrollView!
	@Published var scanLogsInSpan: ScanLogInTimeSpan?
	@Published var span: ScanLogSpan = .today
	@Published var loading: Bool = false

	var kind = EndPointDetailKind.duration {
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
		switch kind {
		case .duration:
			return scanLogs.filter { $0.duration > 0 }
		case .issue:
			return scanLogs.filter { $0.errorCount > 0 }
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableContainer.isHidden = true
		self.chartView.isHidden = true

		$endPointId
			.filter { $0 != nil && !$0!.isEmpty }
			.removeDuplicates()
			.flatMap { [weak self] endPointId -> AnyPublisher<ScanLogInTimeSpan, ResponseError> in
				self?.loading = true
				return BackendAgent.default.listScanLogInSpan(endPoint: endPointId!)
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
					self?.loading = false
				}
			}
			.store(in: &cancellables)

		$loading.sink { [weak self] loading in
			if loading {
				self?.tableContainer.isHidden = true
				self?.chartView.isHidden = true
				self?.progressIndicator.startAnimation(self)
			} else {
				self?.tableContainer.isHidden = false
				self?.chartView.isHidden = false
				self?.progressIndicator.stopAnimation(self)
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
			detailTableView.tableColumns[1].headerCell.stringValue = kind.valueColumnName
		}
	}
}

extension EndPointDetailViewController: NSTableViewDelegate, NSTableViewDataSource {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let identifier = tableColumn!.identifier.rawValue
		let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(identifier), owner: self) as? NSTableCellView
		let scanLog = validScanLogs[row]
		switch identifier {
		case "time":
			let formatter = DateFormatter()
			formatter.dateStyle = .short
			formatter.timeStyle = .short
			view?.textField?.stringValue = formatter.string(from: scanLog.time)
		case "value":
			if kind == .duration {
				view?.textField?.stringValue = scanLog.duration.formatDuration
			} else if kind == .issue {
				view?.textField?.intValue = Int32(scanLog.errorCount)
			}
		case "action":
			break
		default:
			break
		}
		return view
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		guard detailTableView.selectedRow >= 0 else { return }
		let selectedView = detailTableView.view(atColumn: 2, row: detailTableView.selectedRow, makeIfNecessary: true)!
		let vc: EndPointDetailPopupViewController = storyboard!.instantiateController(identifier: "popup")
		vc.kind = kind
		vc.scanLogId = validScanLogs[detailTableView.selectedRow].id
		present(vc, asPopoverRelativeTo: selectedView.bounds, of: selectedView, preferredEdge: .maxX, behavior: .transient)
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		validScanLogs.count
	}
}

extension EndPointDetailViewController {
	func setChartData(_ scanLogsInSpan: ScanLogInTimeSpan, in span: ScanLogSpan) {
		let scanlogs = scanLogsInSpan[span]

		let ys1 = scanlogs.map { self.kind.getValue(log: $0) }

		let yse1 = ys1.enumerated().map { x, y in BarChartDataEntry(x: Double(x), y: Double(y)) }

		let data = BarChartData()
		let ds1 = BarChartDataSet(entries: yse1)
		ds1.colors = ChartColorTemplates.material()
		data.addDataSet(ds1)

		let barWidth = 0.4

		data.barWidth = barWidth
		self.chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: span.indexes(last: scanlogs.last!.time))
		self.chartView.leftAxis.drawLabelsEnabled = false
		let maxY = Double(max(self.kind.maxY, ys1.max()! + self.kind.reservedY))
		self.chartView.leftAxis.axisMaximum = maxY
		self.chartView.rightAxis.axisMaximum = maxY
		self.chartView.rightAxis.valueFormatter = self.kind.valueFormatter

		self.chartView.data = data

		self.chartView.gridBackgroundColor = NSUIColor.white
	}
}
