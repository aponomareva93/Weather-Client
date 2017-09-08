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
    class func createRequest(url: URLConvertible, method: HTTPMethod, responseJSONHandler: @escaping ([String: Any]?, NSError?) -> Void) {
        Alamofire.request(
            url,
            method: method)
            .validate()
            .responseJSON(completionHandler: {(response) in
                
                var error: NSError?
                if response.result.isSuccess {
                    if let value = response.result.value as? [String: Any] {
                        responseJSONHandler(value, nil)
                    } else {
                        print("NetworkManager::Cannot create JSON from response")
                        error = NSError(domain: "weather domain", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create JSON from response"])
                        responseJSONHandler(nil, error)
                    }
                } else {
                    print("NetworkManager::Fetching response error")
                    error = response.result.error as? NSError
                    responseJSONHandler(nil, error)
                }
            })
    }
    
    class func fetchWeather(from city: String?, withHandler: @escaping ([String: Any]?, NSError?) -> Void) -> NSError? {
        if city != nil {
            let cityNameForURL = city!.components(separatedBy: " ").joined(separator: "")
            let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + cityNameForURL + "&appid=" + APIKey.key
            guard let url = URL(string: urlString) else {
                print("NetworkManager::Cannot create url \(urlString)")
                return NSError(domain: "weather domain", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create url for city \(city!)"])
            }
            
            createRequest(url: url, method: .get, responseJSONHandler: withHandler)
            return nil
        } else {
            print("NetworkManager::current city is nil")
            return NSError(domain: "weather domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "City is not defined"])
        }
    }
}

