//
//  CoreContext.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/14.
//

import AppKit
import CoreData
import Foundation

extension NSManagedObjectContext {
	static let main = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	static let add = NSManagedObjectContext.createChildContext(name: "add")
		static let edit = NSManagedObjectContext.createChildContext(name: "edit")

	private static func createChildContext(name: String) -> NSManagedObjectContext {
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.name = name
		context.parent = Self.main
		return context
	}
}
