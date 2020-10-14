//
//  AppDelegate+DebugHelpers.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/14.
//

import AppKit
import CoreData
import Foundation

extension AppDelegate {
	func resetCoreData() {
		print("reset core data")
		let models = [ApiEntity.self, EndPointEntity.self]
		for model in models {
			purgeModel(type: model)
		}
	}

	func purgeModel(type: NSManagedObject.Type) {
		for e in try! persistentContainer.viewContext.fetch(type.fetchRequest()) {
			persistentContainer.viewContext.delete(e as! NSManagedObject)
		}
		try? persistentContainer.viewContext.save()
	}
}
