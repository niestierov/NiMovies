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
        guard NetworkReachabilityService.isConnectedToInternet else {
            completion(.failure(NetworkError.noInternetConnection))
            return
        }
        
        guard let url = endpoint.url else {
            completion(.failure(NetworkError.noInternetConnection))
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
            guard NetworkReachabilityService.isConnectedToInternet else {
                completion(.failure(NetworkError.noInternetConnection))
                return
            }
            
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

enum NetworkError: Error, LocalizedError {
    case noInternetConnection
    case invalidUrl
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl, .invalidData:
            AppConstant.defaultErrorMessage
        case .noInternetConnection:
            AppConstant.noInternetConnectionErrorMessage
        }
    }
}
