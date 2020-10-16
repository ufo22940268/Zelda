//
//  EndPointDetailViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Charts
import Cocoa

// let testScanLogs: ScanLogInTimeSpan = [.minutes: [
//	ScanLog(id: "", time: Date(), duration: 300, errorCount: 1, endPointId: ""),
//	ScanLog(id: "", time: Date() - 10 * 60, duration: 100, errorCount: 1, endPointId: ""),
// ]]
let testScanLogs: ScanLogInTimeSpan = [.minutes: Array(0..<5).map { i -> ScanLog in ScanLog(id: "", time: Date() - TimeInterval(60*5*i), duration: Double.random(in: 0.0..<50), errorCount: Int.random(in: 0..<3), endPointId: "") }]

class EndPointDetailViewController: NSViewController {
	@IBOutlet var chartView: BarChartView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		setChartData()
	}
}
