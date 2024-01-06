//
//  NetworkReachabilityService.swift
//  NiMovies
//
//  Created by Denys Niestierov on 06.01.2024.
//

import Alamofire

final class NetworkReachabilityService {
    static var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
