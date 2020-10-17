//
//  EndPointDetailViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Charts
import Cocoa

let testScanLogs: ScanLogInTimeSpan = [.minutes: Array(0..<SCAN_LOG_COUNT).map { i -> ScanLog in
	ScanLog(id: "", time: Date() - TimeInterval(60*5*i), duration: Double.random(in: 0.0..<50), errorCount: Int.random(in: 0..<3), endPointId: "")
}]

class EndPointDetailViewController: NSViewController {
	@IBOutlet var chartView: BarChartView!

	var span: ScanLogSpan = .minutes
	var scanlogs: [ScanLog] = testScanLogs[.minutes]!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		setChartData()
	}
}
