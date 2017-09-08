//
//  NetworkManager.swift
//  Weather Client
//
//  Created by anna on 07.09.17.
//  Copyright © 2017 anna. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    class func createRequest(url: URLConvertible, method: HTTPMethod, responseJSONHandler: @escaping ([String: Any]?) -> Void) {
        Alamofire.request(
            url,
            method: method)
            .validate()
            .responseJSON(completionHandler: {(response) in
                guard response.result.isSuccess else {
                    print("NetworkManager::Fethcing response error")
                    return
                }
                
                guard let value = response.result.value as? [String: Any] else {
                    print("NetworkManager::Cannot create JSON from response")
                    return
                }
                responseJSONHandler(value)
            })
    }
    
    class func fetchWeather(from city: String, withHandler: @escaping ([String: Any]?) -> Void) {
        let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=" + APIKey.key
        guard let url = URL(string: urlString) else {
            print("NetworkManager::Cannot create url \(urlString)")
            return
        }
        
        createRequest(url: url, method: .get, responseJSONHandler: withHandler)
    }
}
