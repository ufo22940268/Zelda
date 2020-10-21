//
//  Combine+Helpers.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/16.
//

import Foundation
import CoreData
import Combine
import SwiftyJSON

extension Publisher {
	func parseArrayObjects<T>(to entity: T.Type) -> AnyPublisher<[T], Self.Failure> where Self.Output == JSON, T: Decodable {
		Publishers.Map(upstream: self) { json in
			json.result.arrayValue.map { json -> T in
				try! JSONDecoder.backendDecoder.decode(entity, from: json.rawData())
			}
		}
		.receive(on: DispatchQueue.main)
		.eraseToAnyPublisher()
	}

	func parseObject<T>(to entity: T.Type) -> AnyPublisher<T, Self.Failure> where Self.Output == JSON, T: Decodable {
		Publishers.Map(upstream: self) { json in
			try! JSONDecoder.backendDecoder.decode(entity, from: json.result.rawData())
		}
		.receive(on: DispatchQueue.main)
		.eraseToAnyPublisher()
	}
}

extension Publisher where Output == Response, Failure == ResponseError {
	func eraseToVoidAnyPublisher() -> AnyPublisher<Void, ResponseError> {
		map { _ in () }
			.eraseToAnyPublisher()
	}
}
