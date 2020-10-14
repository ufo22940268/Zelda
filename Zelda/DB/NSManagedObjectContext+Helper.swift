//
//  NSFetchRequest+Helper.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/14.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
	func fetchMany<T>(_ type: T.Type, _ format: String? = nil, _ argList: String...) throws -> [T] where T: NSManagedObject {
		let req = T.fetchRequest() as! NSFetchRequest<T>
		if let format = format {
			req.predicate = NSPredicate(format: format, argumentArray: argList)
		}
		do {
			return try fetch(req)
		} catch {
			throw error
		}
	}

	func fetchOne<T>(_ type: T.Type, _ format: String? = nil, _ argList: CVarArg...) throws -> T? where T: NSManagedObject {
		let req = T.fetchRequest() as! NSFetchRequest<T>
		if let format = format {
			req.predicate = NSPredicate(format: format, argumentArray: argList)
		}

		do {
			return try fetch(req).first
		} catch {
			throw error
		}
	}
}
