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

struct Weather: JSONMappable {
    var description: String?
    var temperature: Celsius?
    var humidity: Double?
    var pressure: mmHg?
    var windSpeed: Double?
    var iconURL: URL?

    init(fromJSON JSON: [String: Any]?) throws {
        if let mainSection = JSON?["main"] as? [String: Any] {
            if let temperatureInKelvins = mainSection["temp"] as? Double {
                temperature = temperatureInKelvins.fromKelvinToCelsius()
            }

            humidity = mainSection["humidity"] as? Double

            if let pressureInHPa = mainSection["pressure"] as? Double {
                pressure = pressureInHPa.fromHPaTommHg()
            }
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
                let urlString = "http://openweathermap.org/img/w/" + icon + ".png"
                if let url = URL(string: urlString) {
                    iconURL = url
                } else {
                    print("Weather::init:Cannot fetch icon from url")
                }
            } else {
                print("Weather::init:Cannot fetch icon id from JSON")
            }
        } else {
            print("Weather::init:Cannot parse \"weather\"-section")
        }

        guard description != nil,
            temperature != nil,
            humidity != nil,
            pressure != nil,
            windSpeed != nil,
            iconURL != nil else {
            let error = NSError(domain: Constants.invalidJSONDataError.domain,
                                code: Constants.invalidJSONDataError.code,
                                userInfo: Constants.invalidJSONDataError.userInfo)
            throw error
        }
    }
}

fileprivate extension Double {
    func fromKelvinToCelsius() -> Celsius {
        return self - 273.15
    }

    func fromHPaTommHg() -> mmHg {
        return self * 0.75
    }
}

fileprivate extension Constants {
    static let invalidJSONDataError = (domain: "weather init domain",
                               code: 1,
                               userInfo: [NSLocalizedDescriptionKey: "Impossible to fetch weather parameters from JSON data"])
}
