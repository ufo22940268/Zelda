//
//  EndPointDetailContainer.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/20.
//

import Foundation

protocol EndPointDetailContainer {
	var endPointId: String! { get set }
	var loadable: EndPointLoadable! {get set}
}
