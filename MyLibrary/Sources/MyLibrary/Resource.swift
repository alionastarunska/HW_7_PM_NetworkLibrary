//
//  Resource.swift
//  
//
//  Created by Aliona Starunska on 09.03.2021.
//

import Foundation

public protocol Resource {
    
    associatedtype Response: Codable
    
    var url: String { get }
    var requestBody: [String: Any] { get }
    var method: Method { get }
    var headers: [String: String] { get }
}
