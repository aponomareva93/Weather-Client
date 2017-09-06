//
//  WeatherViewController.swift
//  Weather Client
//
//  Created by anna on 05.09.17.
//  Copyright © 2017 anna. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import Kingfisher

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var city: CLPlacemark? {
        didSet {
            title = city!.locality
        }
    }
    
    private var weatherParameters = Dictionary<String, Bool>()//dictionary ["parameter name":"is defined"] for parse errors detecting
    
    private var apiKey: String?
    private let placeholderImage = UIImage(named: "no-image.png")
    private let apiKeyFile = (fileName: "apikey", fileExtension: "txt")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconImageView?.image = placeholderImage
        if readKeyFromFile() {
            fetchWeater()
        }
    }
    
    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func readKeyFromFile() -> Bool {
        if let path = Bundle.main.path(forResource: apiKeyFile.fileName, ofType: apiKeyFile.fileExtension) {
            do {
                apiKey = try String(contentsOfFile: path)
                apiKey = apiKey!.trimmingCharacters(in: .newlines) //delete new line at the end of read string
                return true
            } catch {
                createAlert(title: "Error", message: error.localizedDescription)
                return false
            }
        } else {
            createAlert(title: "API Key not found", message: "Cannot find API key for OpenWeatherMap API")
            return false
        }
    }
    
    private func fetchWeater () {
        let cityName = city!.locality!.components(separatedBy: " ").joined(separator: "")//if city name has space in the middle
        
        //trying to find the chosen city in OpenWeatherMap API
        let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + cityName + "&appid=" + apiKey!
        guard let url = URL(string: urlString) else {
            createAlert(title: "City not found", message: "Cannot find city \(city!.locality!) in OpenWeatherMap")
            temperatureLabel.text = temperatureLabel.text! + "-"
            humidityLabel.text = humidityLabel.text! + "-"
            pressureLabel.text = pressureLabel.text! + "-"
            windSpeedLabel.text = windSpeedLabel.text! + "-"
            weatherDescriptionLabel.text = weatherDescriptionLabel.text! + "-"
            return
        }
        
        //trying to perform request
        Alamofire.request(
            url,
            method: .get)
            .validate()
            .responseJSON { [weak self] (response) -> Void  in
                guard response.result.isSuccess else {
                    self?.createAlert(title: "Fetching error", message: "Error while fetching: \(response.result.error)")
                    return
                }
                
                guard let JSONValue = response.result.value as? [String: Any] else {
                    self?.createAlert(title: "Broken data", message: "Malformed data received from service")
                    return
                }
                self?.parseJSON(value: JSONValue)
        }
    }
    
    private func parseJSON(value: [String: Any]) {
        //try to fetch temperature, humidity and pressure ("main" section)
        if let mainSection = value["main"] as? [String: Any] {
            //temperature
            if let temperature = mainSection["temp"] as? Double {
                weatherParameters["temperature"] = true
                temperatureLabel.text = temperatureLabel.text! + String(format: "%.0f", temperature - 273.15) + "℃"
            } else {
                weatherParameters["temperature"] = false
                temperatureLabel.text = temperatureLabel.text! + "-"
            }
            
            //humidity
            if let humidity = mainSection["humidity"] as? Double {
                weatherParameters["humidity"] = true
                humidityLabel.text = humidityLabel.text! + String(format: "%.0f", humidity) + "%"
            } else {
                weatherParameters["humidity"] = false
                humidityLabel.text = humidityLabel.text! + "-"
            }
            
            //pressure
            if let pressure = mainSection["pressure"] as? Double {
                weatherParameters["pressure"] = true
                pressureLabel.text = pressureLabel.text! + String(format: "%.0f", pressure * 0.75) + " mmHg"
            } else {
                weatherParameters["pressure"] = false
                pressureLabel.text = pressureLabel.text! + "-"
            }
        } else {
            weatherParameters["temperature"] = false
            weatherParameters["humidity"] = false
            weatherParameters["pressure"] = false
            temperatureLabel.text = temperatureLabel.text! + "-"
            humidityLabel.text = humidityLabel.text! + "-"
            pressureLabel.text = pressureLabel.text! + "-"
        }
        
        //try to fetch wind speed ("wind" section)
        if  let windSection = value["wind"] as? [String: Any] {
            if let windSpeed = windSection["speed"] as? Double {
                weatherParameters["wind speed"] = true
                windSpeedLabel.text = windSpeedLabel.text! + String(format: "%.0f", windSpeed) + " meter/sec"
            } else {
                weatherParameters["wind speed"] = false
                windSpeedLabel.text = windSpeedLabel.text! + "-"
            }
        } else {
            weatherParameters["wind speed"] = false
            windSpeedLabel.text = windSpeedLabel.text! + "-"
        }
        
        //try to fetch weather description ("weather" section)
        if let weatherSection = value["weather"] as? [[String: Any]] {
            var description = String()
            for section in weatherSection {
                if section["main"] != nil {
                    description = description + (section["main"] as! String) + ","
                }
            }
            if !description.isEmpty { //if description not empty remove last ","-symbol
                weatherParameters["description"] = true
                description.remove(at: description.index(before: description.endIndex))
            } else {
                weatherParameters["description"] = false
                weatherDescriptionLabel.text = weatherDescriptionLabel.text! + "-"
            }
            weatherDescriptionLabel.text = weatherDescriptionLabel.text! + "\(description)"
            
            //fetch image
            if let icon = weatherSection[0]["icon"] as? String {
                let imageURL = URL(string: String("http://openweathermap.org/img/w/" + icon + ".png"))
                if let url = imageURL {
                    spinner.startAnimating()
                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        DispatchQueue.main.async {
                            self?.iconImageView.kf.setImage(with: url, placeholder: self?.placeholderImage)
                            self?.spinner.stopAnimating()
                        }
                    }
                }
            }
        } else {
            weatherParameters["description"] = false
            weatherDescriptionLabel.text = weatherDescriptionLabel.text! + "-"
        }
        
        //create alert if some parameters are unavailable
        var alertMessage = "The following parameters are unavailable: "
        var isError = false
        for parameter in weatherParameters {
            if !parameter.value {
                isError = true
                alertMessage = alertMessage + parameter.key + ","
            }
        }
        if isError {
            alertMessage.remove(at: alertMessage.index(before: alertMessage.endIndex)) //remove last ","-symbol
            createAlert(title: "Parsing JSON error", message: alertMessage)
        }
    }
}
