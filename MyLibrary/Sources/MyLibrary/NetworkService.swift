//
//  NetworkService.swift
//  
//
//  Created by Aliona Starunska on 08.03.2021.
//

import Foundation

public protocol NetworkService {
    func execute<Request: Resource>(request: Request,
                                    success: @escaping (Request.Response) -> (),
                                    failure: @escaping (Error) -> ())
}

public final class DefaultNetworkService: NetworkService {
    
    private let errorParser: ErrorParseable
    private let defaultHeaders: [String: String]
    
    public init(errorParser: ErrorParseable, defaultHeaders: [String: String]) {
        self.errorParser = errorParser
        self.defaultHeaders = defaultHeaders
    }
    
    public convenience init() {
        self.init(errorParser: ErrorParser(), defaultHeaders: Constants.headers)
    }
    
    public func execute<Request: Resource>(request: Request,
                                           success: @escaping (Request.Response) -> (),
                                           failure: @escaping (Error) -> ()) {
        guard let url = URL(string: request.url) else {
            failure(NSError.badRequest)
            return
        }
        
        var task = URLRequest(url: url)
        task.httpMethod = request.method.rawValue
        ParameterEncoder.encode(parameters: request.requestBody, task: &task, for: request.method)
        
        defaultHeaders.keys.forEach({task.setValue(defaultHeaders[$0], forHTTPHeaderField: $0)})
        request.headers.keys.forEach({task.setValue(request.headers[$0], forHTTPHeaderField: $0)})
        
        URLSession.shared.dataTask(with: task) { [weak self] data, response, error in
            let result = self?.errorParser.parse(response: response as? HTTPURLResponse, data: data, error: error)
            switch result {
            case .failure(let error):
                failure(error)
            case .success(let data):
                do {
                    let decodedResult = try JSONDecoder().decode(Request.Response.self, from: data)
                    success(decodedResult)
                } catch {
                    failure(NSError.decoderError)
                }
            case .none:
                failure(NSError.badRequest)
            }
        }.resume()
        
    }
}

// MARK: - Private

fileprivate extension NSError {
    static var badRequest: NSError { return NSError(domain: "Bad Request", code: 400, userInfo: nil) }
    static var decoderError: NSError { return NSError(domain: "Unable to decode response", code: 400, userInfo: nil) }
}

fileprivate enum Constants {
    static var headers: [String: String] {
        return ["Accept": "application/json",
                "Content-type": "application/json"]
    }
}
