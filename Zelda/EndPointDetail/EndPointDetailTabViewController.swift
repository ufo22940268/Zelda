//
//  EndPointDetailTabViewController.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/19.
//

import Cocoa
import Combine

protocol EndPointLoadable {
	func load(endPoint: String)
	func onSelectSpan(_ span: ScanLogSpan)
}

protocol EndPointDetailLoadable: EndPointLoadable {
	func setIndicator(_ indicator: EndPointDetailKind)
	var endPointId: String? { get set }
	var spanScanLogs: ScanLogInTimeSpan? { get set }
}


protocol IEndPointDetailTab {
	var containerView: NSTabView! { get }
}

class EndPointDetailTabViewController: NSTabViewController, IEndPointDetail, IEndPointDetailTab {
	@Published var endPointId: String?
	var cancellables = Set<AnyCancellable>()
	@Published var scanLogsInSpan: ScanLogInTimeSpan?

	@IBOutlet var containerView: NSTabView!

	var loadables: [EndPointDetailLoadable] {
		tabViewItems.map { item -> EndPointDetailLoadable? in
			if let loadable = (item.viewController as? EndPointDetailContainer)?.loadable {
				return loadable
			} else {
				return nil
			}
		}.filter { $0 != nil }.map { $0! }
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		containerView.isHidden = true
		$endPointId
			.filter { $0 != nil && !$0!.isEmpty }
			.removeDuplicates()
			.flatMap {
				BackendAgent.default.listScanLogInSpan(endPoint: $0!)
			}
			.map { span -> ScanLogInTimeSpan? in
				span
			}
			.replaceError(with: nil)
			.map { (scanlogs: ScanLogInTimeSpan?) -> ScanLogInTimeSpan? in
				guard let scanlogs = scanlogs else { return nil }
				var newScanLogs = scanlogs
				newScanLogs.fillGap()
				return newScanLogs
			}
			.assign(to: &$scanLogsInSpan)
		
		$scanLogsInSpan
			.filter { $0 != nil  }
			.sink { [weak self] (span) in
				self?.loadables.forEach {
					var n = $0
					n.spanScanLogs = span
				}
				self?.containerView.isHidden = false
			}
			.store(in: &cancellables)
	}

	override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		if let endPointId = endPointId {
			loadables.forEach { $0.load(endPoint: endPointId) }
		}
	}
}

extension EndPointDetailTabViewController: EndPointLoadable {
	func load(endPoint: String) {
		loadables.forEach { $0.load(endPoint: endPoint) }
		endPointId = endPoint
	}

	func onSelectSpan(_ span: ScanLogSpan) {
		loadables.forEach { $0.onSelectSpan(span) }
	}
}
