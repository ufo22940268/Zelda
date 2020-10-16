//
//  EndPointDetailViewController+Chart.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Foundation
import Charts

extension EndPointDetailViewController {
	func setChartData() {
		let xArray = Array(1..<10)
		let ys1 = xArray.map { x in return sin(Double(x) / 2.0 / 3.141 * 1.5) }
		
		let yse1 = ys1.enumerated().map { x, y in return BarChartDataEntry(x: Double(x), y: y) }
		
		let data = BarChartData()
		let ds1 = BarChartDataSet(entries: yse1, label: "Hello")
		ds1.colors = [NSUIColor.red]
		data.addDataSet(ds1)

		let barWidth = 0.4
		let barSpace = 0.05
		let groupSpace = 0.1
		
		data.barWidth = barWidth
		self.chartView.xAxis.axisMinimum = Double(xArray[0])
		self.chartView.xAxis.axisMaximum = Double(xArray[0]) + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(xArray.count)
		self.chartView.leftAxis.drawLabelsEnabled = false
		let line = ChartLimitLine(limit: 0.3)
		line.label = "avg"
		line.labelPosition = .bottomLeft
		line.lineColor = .green
		line.lineDashLengths = [3, 2]
		self.chartView.leftAxis.addLimitLine(line)
		// (0.4 + 0.05) * 2 (data set count) + 0.1 = 1
		data.groupBars(fromX: Double(xArray[0]), groupSpace: groupSpace, barSpace: barSpace)

		self.chartView.data = data
		
		self.chartView.gridBackgroundColor = NSUIColor.white
		
	}
}
