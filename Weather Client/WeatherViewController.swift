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
import SVProgressHUD

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
        getWeather()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    private func getWeather () {
        let cityName = city?.locality
        SVProgressHUD.show(withStatus: "Loading")
        if let error = NetworkManager.fetchWeather(from: cityName, withHandler: { [weak self] (responseJSON, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                self?.showAlert(withTitle: "Error", message: error!.localizedDescription, okButtonTapped: {_ = self?.navigationController?.popViewController(animated: true)})
                return
            }
            self?.weather = Weather(fromJSON: responseJSON)
            SVProgressHUD.dismiss()
        }) {
            SVProgressHUD.dismiss()
            showAlert(withTitle: "Error", message: error.localizedDescription, okButtonTapped: {[weak self]  in
                _ = self?.navigationController?.popViewController(animated: true)})
        }
    }
    
    private func setLabelText(parameterDescription: String, text: String?, label: UILabel?) {
        if let labelText = text, !labelText.isEmpty {
            label?.text = parameterDescription + ": " + labelText
        } else {
            label?.isHidden = true
        }
    }
    
    private func updateUI() {
        setLabelText(parameterDescription:"Description", text: weather?.description, label: weatherDescriptionLabel)
        setLabelText(parameterDescription:"Temperature, ℃", text: weather?.temperature?.fromDecimalToString(), label: temperatureLabel)
        setLabelText(parameterDescription:"Humidity, %", text: weather?.humidity?.fromDecimalToString(), label: humidityLabel)
        setLabelText(parameterDescription:"Pressure, mmHg", text: weather?.pressure?.fromDecimalToString(), label: pressureLabel)
        setLabelText(parameterDescription:"Wind speed, meter/sec", text: weather?.windSpeed?.fromDecimalToString(), label: windSpeedLabel)
        
        if let iconURL = weather?.iconURL {
            iconImageView.kf.setImage(with: iconURL, placeholder: placeholderImage)
        }
    }
}

extension UIViewController {
    func showAlert(withTitle title: String, message: String, okButtonTapped: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            okButtonTapped?()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
