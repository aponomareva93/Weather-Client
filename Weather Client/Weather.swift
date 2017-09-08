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
typealias mmHg = Double
struct Weather {
    var description: String?
    var temperature: Celsius?
    var humidity: Double?
    var pressure: mmHg?
    var windSpeed: Double?
    var iconURL: URL?
    
    init(fromJSON JSON: [String: Any]?) {
        if let mainSection = JSON?["main"] as? [String: Any] {
            temperature = mainSection["temp"] as? Double
            temperature = temperature?.fromKelvinToCelsius()
            
            humidity = mainSection["humidity"] as? Double
            
            pressure = mainSection["pressure"] as? Double
            pressure = pressure?.fromHPaTommHg()
        } else {
            print("Weather::init:Cannot parse \"main\"-section")
        }
        
        if let windSection = JSON?["wind"] as? [String: Any] {
            windSpeed = windSection["speed"] as? Double
        } else {
            print("Weather::init:Cannot parse \"wind\"-section")
        }
        
        if let weatherSection = JSON?["weather"] as? [[String: Any]] {
            description = String()
            for section in weatherSection {
                if let descriptionPart = section["main"] as? String {
                    description = description! + descriptionPart + ","
                }
            }
            description = description?.trimmingCharacters(in: .punctuationCharacters)
            
            if let icon = weatherSection[0]["icon"] as? String {
                if let url = URL(string: String("http://openweathermap.org/img/w/" + icon + ".png")) {
                    iconURL = url
                } else {
                    print("Weather::init:Cannot fetch icon from url")
                }
            } else {
                print("Weather::init:Cannot fetch icon id from JSON")
            }
        } else {
            print("Weather::weatherinit:Cannot parse \"weather\"-section")
        }
    }
}

extension Celsius {
    func fromKelvinToCelsius() -> Celsius {
        return self - 273.15
    }
}

extension mmHg {
    func fromHPaTommHg() -> mmHg {
        return self * 0.75
    }
}

extension Double {
    func fromDecimalToString() -> String {
        return String(format: "%.0f", self)
    }
}
