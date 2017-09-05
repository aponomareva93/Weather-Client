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

class WeatherViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var city: CLPlacemark? {
        didSet {
            title = city!.locality
        }
    }
    
    private var apiKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if let path = Bundle.main.path(forResource: "apikey", ofType:"txt") {
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
                
                guard let value = response.result.value as? [String: Any] else {
                    self?.createAlert(title: "Broken data", message: "Malformed data received from service")
                        return
                }
                print(value)
        }
    }
}
