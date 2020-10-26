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
	func setIndicator(_ indicator: EndPointDetailKind)
	var endPointId: String? { get set }
	var spanScanLogs: ScanLogInTimeSpan? { get set }
	var kind: EndPointDetailKind { get set }
	var url: String! { get set }
	func onSelectSpan(_ span: ScanLogSpan)
}

class EndPointDetailViewController: NSViewController, IEndPointDetail {
	// MARK: Internal

	@IBOutlet var chartView: BarChartView!

	@IBOutlet var progressIndicator: NSProgressIndicator!
	@IBOutlet var detailTableView: NSTableView!
	@Published var endPointId: String?
	var url: String!
	var cancellables = Set<AnyCancellable>()

	@IBOutlet var tableContainer: NSScrollView!
	@Published var loading: Bool = false

	var kind = EndPointDetailKind.duration

	var spanScanLogs: ScanLogInTimeSpan? {
		didSet {
			loadSpanLogs()
		}
	}

	var span: ScanLogSpan = .today {
		didSet {
			loadSpanLogs()
		}
	}

	var scanLogs: [ScanLog] {
		if let scanLogsInSpan = spanScanLogs {
			return scanLogsInSpan[span]
		} else {
			return []
		}
	}

	var tableScanLogs: [ScanLog] {
		let logs = self.scanLogs.sorted { $0.time > $1.time }
		switch kind {
		case .duration:
			return logs.filter { $0.duration > 0 }
		case .issue:
			return logs.filter { $0.errorCount > 0 }
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableContainer.isHidden = true
		chartView.isHidden = true

		$loading
			.dropFirst()
			.sink { [weak self] loading in
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

		loadSpanLogs()

		setupObservers()
	}

	func setIndicator(_ indicator: EndPointDetailKind) {
		kind = indicator
	}

	func onSelectSpan(_ span: ScanLogSpan) {
		self.span = span
		detailTableView.reloadData()
	}

	func setChartData(_ scanLogsInSpan: ScanLogInTimeSpan, in span: ScanLogSpan) {
		let scanlogs = scanLogsInSpan[span]

		let ys1 = scanlogs.map { self.kind.getValue(log: $0) }

		let yse1 = ys1.enumerated().map { x, y in BarChartDataEntry(x: Double(x), y: Double(y)) }

		let data = BarChartData()
		let ds1 = BarChartDataSet(entries: yse1)
		ds1.colors = ChartColorTemplates.material()
		data.addDataSet(ds1)

		let barWidth = 0.2
		data.barWidth = barWidth
		chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: span.indexes(last: scanlogs.last!.time))
		chartView.leftAxis.drawLabelsEnabled = false
		let maxY = Double(max(kind.maxY, ys1.max()! + kind.reservedY))
		chartView.leftAxis.axisMaximum = maxY
		chartView.rightAxis.axisMaximum = maxY
		chartView.rightAxis.valueFormatter = kind.valueFormatter

		chartView.data = data

		chartView.gridBackgroundColor = NSUIColor.white
	}

	@IBAction func onDoubleClick(_ sender: Any) {
		guard detailTableView.selectedRow != -1 else { return }
		presentDetail(row: detailTableView.selectedRow)
	}

	@IBAction func onClickInfo(_ sender: NSButton) {
		presentDetail(row: Int(sender.identifier!.rawValue)!)
	}

	// MARK: Fileprivate

	fileprivate func loadSpanLogs() {
		if !isViewLoaded { return }
		if let spanScanLogs = spanScanLogs {
			loading = false
			setChartData(spanScanLogs, in: span)
			detailTableView.reloadData()
		} else {
			loading = true
		}

		updateTableColumn()
	}

	fileprivate func updateTableColumn() {
		if let detailTableView = detailTableView {
			detailTableView.tableColumns[1].headerCell.stringValue = kind.valueColumnName
		}
	}

	// MARK: Private

	private func setupObservers() {
		NotificationCenter.default.publisher(for: .spanChanged)
			.sink { [weak self] _ in
				self?.span = ConfigStore.shared.getSpan()
			}
			.store(in: &cancellables)
	}

	private func presentDetail(row: Int) {
		let recordDetail: RecordDetailViewController = storyboard!.instantiateController(identifier: "recordDetail")
		recordDetail.scanLogId = tableScanLogs[row].id
		recordDetail.title = url
		presentAsModalWindow(recordDetail)
	}
}

extension EndPointDetailViewController: NSTableViewDelegate, NSTableViewDataSource {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let identifier = tableColumn!.identifier.rawValue
		let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(identifier), owner: self) as? NSTableCellView
		let scanLog = tableScanLogs[row]
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
			(view as! EndPointInfoCellView).row = row
		default:
			break
		}
		return view
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		tableScanLogs.count
	}
}
