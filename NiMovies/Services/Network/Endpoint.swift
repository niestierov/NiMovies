//
//  Endpoint.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import Foundation
import Alamofire

class Endpoint<T: Decodable>: Requestable {
    typealias ResponseType = T
    
    // MARK: - Properties -
    
    let url: URL?
    let parameters: [String: Any]
    let method: HTTPMethod
    let encoding: ParameterEncoding
    
    // MARK: - Init -
    
    init(
        url: URL?,
        parameters: [String: Any] = [:],
        method: HTTPMethod,
        encoding: ParameterEncoding = URLEncoding.default
    ) {
        self.url = url
        self.parameters = parameters
        self.method = method
        self.encoding = encoding
    }
}
