//
//  EndPointDetailVioewController+Loadable.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/20.
//

import Foundation


extension EndPointDetailViewController: EndPointDetailLoadable {
	func setIndicator(_ indicator: EndPointDetailKind) {
		self.kind = indicator
	}

	func fillScanLogGap(_ scanLogs: inout ScanLogInTimeSpan) {
		scanLogs.fillGap()
	}


	func onSelectSpan(_ span: ScanLogSpan) {
		self.span = span
		detailTableView.reloadData()
	}
}
