//
//  URL+Validate.swift
//  Zelda
//
//  Created by Frank Cheng on 2020/10/14.
//

import Combine
import Foundation
import SwiftyJSON

extension ApiHelper {
	static func validate(url: String) -> AnyPublisher<ValidateURLResult, Never> {
		if let urlObj = URL(string: url) {
			let cancellable = URLSession.shared.dataTaskPublisher(for: urlObj)
				.tryMap { ar in
					let errorLog = ResponseLog(data: ar.0, response: ar.1)
					if !ar.response.ok {
						return ValidateURLResult.requestError(errorLog)
					}

					if (try JSON(data: ar.data)).count > 0 {
						return ValidateURLResult.ok
					} else {
						return ValidateURLResult.jsonError(errorLog)
					}
				}
				.catch { error -> AnyPublisher<ValidateURLResult, Never> in
					if let error = error as? URLError {
						return Just(ValidateURLResult.requestError(ResponseLog(error: error))).eraseToAnyPublisher()
					} else {
						return Just(ValidateURLResult.formatError).eraseToAnyPublisher()
					}
				}
				.eraseToAnyPublisher()
			return cancellable
		} else {
			return Just(ValidateURLResult.pending).eraseToAnyPublisher()
		}
	}
}

enum ValidateURLResult: Equatable {
	case prompt
	case initial
	case formatError
	case requestError(_ responseLog: ResponseLog)
	case jsonError(_ responseLog: ResponseLog)
	case pending
	case ok
	case duplicatedUrl

	// MARK: Internal

	var isProcessing: Bool {
		return self == .pending
	}

	var label: String {
		switch self {
		case .prompt:
			return "地址示例 http://biubiubiu.biz/link/github.json"
		case .initial:
			return ""
		case .formatError:
			return "地址格式不对或不完整, 需要以http://或者https://开头"
		case .duplicatedUrl:
			return "地址已存在"
		case .requestError:
			return "地址请求失败"
		case .jsonError:
			return "返回并不是合法JSON"
		case .pending:
			return "检查中..."
		case .ok:
			return "地址正常"
		}
	}

	var responseLog: ResponseLog? {
		switch self {
		case let .requestError(log):
			return log
		case let .jsonError(log):
			return log
		default:
			return nil
		}
	}

	var hasProfile: Bool {
		responseLog != nil
	}

//	var color: Color? {
//		nil
//	}
	static func == (lhs: ValidateURLResult, rhs: ValidateURLResult) -> Bool {
		lhs.label == rhs.label
	}
}

struct ResponseLog {
	// MARK: Lifecycle

	internal init(header: String, body: String) {
		self.header = header
		self.body = body
	}

	internal init(data: Data, response: URLResponse) {
		if !data.isEmpty {
			body = String(data: data, encoding: .utf8) ?? nil
		}
		if let response = response as? HTTPURLResponse {
			header = response.allHeaderFields.map { String(describing: $0.key) + ":" + String(describing: $0.value) }.joined(separator: "\n")
			statusCode = response.statusCode
		}
	}

	internal init(error: URLError) {
		body = error.localizedDescription
	}

	// MARK: Internal

	var header: String?
	var body: String?
	var statusCode: Int?
}
