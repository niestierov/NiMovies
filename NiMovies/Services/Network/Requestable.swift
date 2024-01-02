//
//  Requestable.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import Foundation
import Alamofire

protocol Requestable {
    associatedtype ResponseType: Decodable
    
    var url: URL? { get }
    var parameters: [String: Any] { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
}

