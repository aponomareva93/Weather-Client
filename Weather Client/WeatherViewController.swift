//
//  WeatherViewController.swift
//  Weather Client
//
//  Created by anna on 07.09.17.
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
    
    var city: CLPlacemark? {
        didSet {
            title = city!.locality
        }
    }
    
    var weather: Weather? {
        didSet {
            updateUI()
        }
    }
    
    private let placeholderImage = UIImage(named: "no-image.png")
    
    override func loadView() {
        if let array = Bundle.main.loadNibNamed("WeatherViewController", owner: self, options: nil) {
            if array.count > 0 {
                self.view = array[0] as? UIView
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //iconImageView?.image = placeholderImage
        getWeather()
    }
    
    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    struct Test {
        var testDouble: Double?
    }
    var test: Test?
    
    private func getWeather () {
        let cityName = city!.locality!.components(separatedBy: " ").joined(separator: "")
        NetworkManager.fetchWeather(from: cityName, withHandler: { [weak self] (responseJSON) in
            self?.weather = Weather(fromJSON: responseJSON)
        })
    }
    
    private func updateUI() {
        if let descriptions = weather?.description,
            !descriptions.isEmpty {
            var descriptionText = String()
            for description in descriptions {
                if description != nil {
                    descriptionText += description! + ","
                }
            }
            descriptionText = descriptionText.trimmingCharacters(in: .punctuationCharacters)
            weatherDescriptionLabel?.text = descriptionText
        } else {
            weatherDescriptionLabel?.isHidden = true
        }
        
        if let temperature = weather?.temperature {
            temperatureLabel?.text = String(format: "%.0f", temperature)
        } else {
            temperatureLabel?.isHidden = true
        }
        
        if let humidity = weather?.humidity {
            humidityLabel?.text = String(format: "%.0f", humidity)
        } else {
            humidityLabel?.isHidden = true
        }
        
        if let pressure = weather?.mmHgPressure {
            pressureLabel?.text = String(format: "%.0f", pressure)
        } else {
            pressureLabel?.isHidden = true
        }
        
        if let windSpeed = weather?.windSpeed {
            windSpeedLabel?.text = String(format: "%.0f", windSpeed)
        } else {
            windSpeedLabel?.isHidden = true
        }
        
        if let iconURL = weather?.iconURL {
            iconImageView.kf.setImage(with: iconURL, placeholder: placeholderImage)
        }
    }
}
