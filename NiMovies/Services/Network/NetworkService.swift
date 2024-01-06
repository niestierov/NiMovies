//
//  NetworkService.swift
//  NiMovies
//
//  Created by Denys Niestierov on 02.01.2024.
//

import Foundation
import Alamofire

protocol NetworkService {
    func request<T: Requestable>(
        endpoint: T,
        completion: @escaping (Result<T.ResponseType?, Error>) -> Void
    )
}

final class DefaultNetworkService: NetworkService {
    
    //MARK: - Internal -
    
    func request<T: Requestable>(
        endpoint: T,
        completion: @escaping (Result<T.ResponseType?, Error>) -> Void
    ) {
        guard let url = endpoint.url else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }
        
        AF.request(
            url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.encoding
        ).responseDecodable(
            of: T.ResponseType.self,
            decoder: JSONDecoder.default
        ) { response in
            guard response.data != nil else {
                completion(.failure(NetworkError.invalidData))
                return
            }

            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum NetworkError: Error {
    case invalidUrl
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .invalidUrl:
            return "url_invalid"
        case .invalidData:
            return "retrieved_data_invalid"
        }
    }
}
