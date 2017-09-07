//
//  Weather.swift
//  Weather Client
//
//  Created by anna on 07.09.17.
//  Copyright © 2017 anna. All rights reserved.
//

import Foundation
import UIKit

typealias Celsius = Double
struct Weather {
    var description = Array<String?>()
    var temperature: Celsius?
    var humidity: Double?
    var mmHgPressure: Double?
    var windSpeed: Double?
    var iconURL: URL?
    
    init(fromJSON JSON: [String: Any]?) {
        if let mainSection = JSON?["main"] as? [String: Any] {
            temperature = mainSection["temp"] as? Double
            humidity = mainSection["humidity"] as? Double
            mmHgPressure = mainSection["pressure"] as? Double
        } else {
            print("Weather::weather:Cannot parse \"main\"-section")
        }
        
        if let windSection = JSON?["wind"] as? [String: Any] {
            windSpeed = windSection["speed"] as? Double
        } else {
            print("Weather::weather:Cannot parse \"wind\"-section")
        }
        
        if let weatherSection = JSON?["weather"] as? [[String: Any]] {
            print(weatherSection)
            for section in weatherSection {
                description.append(section["main"] as? String)
            }
            
            if let icon = weatherSection[0]["icon"] as? String {
                if let url = URL(string: String("http://openweathermap.org/img/w/" + icon + ".png")) {
                    iconURL = url
                } else {
                    print("Weather::weather:Cannot fetch icon from url")
                }
            } else {
                print("Weather::weather:Cannot fetch icon id from JSON")
            }
        } else {
            print("Weather::weather:Cannot parse \"weather\"-section")
        }
    }
}

