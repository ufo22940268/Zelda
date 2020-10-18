//
//  EndPointDetailViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Charts
import Cocoa
import Combine

let testScanLogs: ScanLogInTimeSpan = [
	.today: Array(0..<SCAN_LOG_COUNT).map { i -> ScanLog in
		ScanLog(id: "", time: Date() - TimeInterval(60*5*i), duration: Double.random(in: 0.0..<50), errorCount: Int.random(in: 0..<3), endPointId: "")},
	.week: Array(0..<SCAN_LOG_COUNT).map { i -> ScanLog in
		ScanLog(id: "", time: Date() - TimeInterval(60*5*i), duration: Double.random(in: 0.0..<50), errorCount: Int.random(in: 0..<3), endPointId: "")}
]

enum EndPointIndicator {
	case duration
	case error
	
	func getValue(log: ScanLog) -> Int {
		switch self {
		case .duration:
			return Int(log.duration)
		case .error:
			return log.errorCount
		}
	}
}

class EndPointDetailViewController: NSViewController {
	@IBOutlet var chartView: BarChartView!

	@Published var span: ScanLogSpan = .today
	var indicator = EndPointIndicator.duration
	var cancellables =  Set<AnyCancellable>()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		setChartData(span: self.span)
		
		$span.sink { [weak self] span in
			self?.setChartDa ta(span: span)
		}
		.store(in: &cancellables)
	}
	
	@IBAction func onSelectSpan(_ button: NSPopUpButton) {
		span = ScanLogSpan(id: button.selectedItem!.identifier!.rawValue)
	}
}
