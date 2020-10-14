//
//  EndPoointEditViewController+Type.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/14.
//

import CoreData
import Foundation

enum EndPointEditType {
	case add
	case edit

	// MARK: Internal

	var context: NSManagedObjectContext {
		switch self {
		case .add:
			return .add
		case .edit:
			return .edit
		}
	}
}
