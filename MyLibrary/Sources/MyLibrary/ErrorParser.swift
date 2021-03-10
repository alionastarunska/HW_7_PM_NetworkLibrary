//
//  File.swift
//  
//
//  Created by Aliona Starunska on 08.03.2021.
//

import Foundation

public enum ParserResult {
    case success(Data)
    case failure(Error)
}

public protocol ErrorParseable {
    func parse(response: HTTPURLResponse?, data: Data?, error: Error?) -> ParserResult
}

public final class ErrorParser: ErrorParseable {
    
    public init() {}
    
    public func parse(response: HTTPURLResponse?, data: Data?, error: Error?) -> ParserResult {
        if let error = error {
            return .failure(error)
        } else {
            if let response = response, !(200...300).contains(response.statusCode) {
                return .failure(NSError(domain: "", code: response.statusCode, userInfo: nil))
            }
        }
        guard let data = data else { return .failure(NSError(domain: "Parser Error", code: 400, userInfo: nil)) }
        return .success(data)
    }
}
