//
//  EndPointDetailViewController+Chart.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Charts
import Foundation

extension EndPointDetailViewController {
	func setChartData(_ scanLogsInSpan: ScanLogInTimeSpan, in span: ScanLogSpan) {
		let scanlogs = scanLogsInSpan[span]

		let ys1 = scanlogs.map { self.indicator.getValue(log: $0) }

		let yse1 = ys1.enumerated().map { x, y in BarChartDataEntry(x: Double(x), y: Double(y)) }

		let data = BarChartData()
		let ds1 = BarChartDataSet(entries: yse1)
		ds1.colors = ChartColorTemplates.material()
		data.addDataSet(ds1)

		let barWidth = 0.4

		data.barWidth = barWidth
		self.chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: span.indexes(last: scanlogs.last!.time))
		self.chartView.leftAxis.drawLabelsEnabled = false
		let maxY = Double(max(100, ys1.max()!))
		self.chartView.leftAxis.axisMaximum = maxY
		self.chartView.rightAxis.axisMaximum = maxY
		self.chartView.rightAxis.valueFormatter = self.indicator.valueFormatter

		let line = ChartLimitLine(limit: Double(ys1.reduce(.zero, +)) / Double(ys1.count))
		line.drawLabelEnabled = false
		line.lineColor = .green
		line.lineDashLengths = [6, 2]
		self.chartView.leftAxis.addLimitLine(line)

		self.chartView.data = data

		self.chartView.gridBackgroundColor = NSUIColor.white
	}
}
