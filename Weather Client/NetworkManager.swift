//
//  NetworkManager.swift
//  Weather Client
//
//  Created by anna on 07.09.17.
//  Copyright © 2017 anna. All rights reserved.
//

import Foundation
import Alamofire

protocol JSONMappable {
    init(fromJSON JSON: [String: Any]?) throws
}

enum Response<T: JSONMappable> {
    case success(T)
    case failure(NSError)
}

class NetworkManager {
    class func baseRequest<T: JSONMappable>(url: URLConvertible?,
                             method: HTTPMethod,
                             completion: @escaping (Response<T>) -> Void) {

        guard let url = url else {
            let error = NSError(domain: Constants.invalidURLError.domain,
                                code: Constants.invalidURLError.code,
                                userInfo: Constants.invalidURLError.userInfo)
            completion(.failure(error))
            return
        }

        Alamofire.request(
            url,
            method: method)
            .validate()
            .responseJSON(completionHandler: {response in
                switch response.result {
                case .success(let value):
                    if let value = value as? [String: Any] {
                        do {
                            let object = try T(fromJSON: value)
                            completion(.success(object))
                        } catch {
                            completion(.failure(error as NSError))
                        }
                    } else {
                        print("NetworkManager::Cannot create JSON from response")
                        let error = NSError(domain: Constants.invaliJSONResponseError.domain,
                                            code: Constants.invaliJSONResponseError.code,
                                            userInfo: Constants.invaliJSONResponseError.userInfo)
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error as NSError))
                }
            })
    }

    class func fetchWeather<T: JSONMappable>(from city: String?,
                            withHandler: @escaping (Response<T>) -> Void) {
        var url: URL?
        if let city = city {
            let cityNameForURL = city.components(separatedBy: " ").joined(separator: "")
            let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" +
                cityNameForURL +
                "&appid=" +
                APIKey.key
            url = URL(string: urlString)
        } else {
            print("NetworkManager::current city is nil")
        }
        baseRequest(url: url, method: .get, completion: withHandler)
    }
}

fileprivate extension Constants {
    static let invalidURLError = (domain: "weather domain",
                                  code: 1,
                                  userInfo: [NSLocalizedDescriptionKey:
                                    "Cannot create url for current request"])
    static let invaliJSONResponseError = (domain: "weather domain",
                                          code: 2,
                                          userInfo: [NSLocalizedDescriptionKey:
                                            "Cannot create JSON from response"])
}
