//
//  File.swift
//  
//
//  Created by Aliona Starunska on 08.03.2021.
//

import Foundation

public final class ParameterEncoder {
    
    public static func encode(parameters: [String: Any], task: inout URLRequest, for method: Method) {
        switch method {
        case .get, .delete:
            guard let url = task.url else { return }
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                urlComponents.queryItems = [URLQueryItem]()
                
                for (key, value) in parameters {
                    let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))
                    urlComponents.queryItems?.append(queryItem)
                }
                task.url = urlComponents.url
            }
        default:
            do {
                let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                task.httpBody = jsonAsData
            } catch {
                
            }
        }
    }
}
