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

    @IBOutlet private weak var weatherDescriptionLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var pressureLabel: UILabel!
    @IBOutlet private weak var windSpeedLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!

    private var city: CLPlacemark?

    private var weather: Weather? {
        didSet {
            updateUI()
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

    init(city: CLPlacemark?) {
        super.init(nibName: nil, bundle: nil)
        self.city = city
        if let city = city {
            title = city.locality
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func getWeather () {
        let cityName = city?.locality
        SVProgressHUD.show(withStatus: "Loading")
        NetworkManager.fetchWeather(
            from: cityName,
            withHandler: { [weak self] (responseObject: Response<Weather>) in
                switch responseObject {
                case .success(let weather):
                    self?.weather = weather
                    SVProgressHUD.dismiss()
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    self?.showAlert(withTitle: "Error",
                                    message: error.localizedDescription,
                                    okButtonTapped: {
                                        _ = self?.navigationController?.popViewController(animated: true)
                    })
                }
        })
    }

    private func setLabelText(parameterDescription: String, text: String?, label: UILabel?) {
        if let labelText = text, !labelText.isEmpty {
            label?.text = parameterDescription + ": " + labelText
        } else {
            label?.isHidden = true
        }
    }

    private func updateUI() {
        setLabelText(parameterDescription:"Description",
                     text: weather?.description,
                     label: weatherDescriptionLabel)
        setLabelText(parameterDescription:"Temperature, ℃",
                     text: weather?.temperature?.fromDecimalToString(),
                     label: temperatureLabel)
        setLabelText(parameterDescription:"Humidity, %",
                     text: weather?.humidity?.fromDecimalToString(),
                     label: humidityLabel)
        setLabelText(parameterDescription:"Pressure, mmHg",
                     text: weather?.pressure?.fromDecimalToString(),
                     label: pressureLabel)
        setLabelText(parameterDescription:"Wind speed, meter/sec",
                     text: weather?.windSpeed?.fromDecimalToString(),
                     label: windSpeedLabel)

        if let iconURL = weather?.iconURL {
            iconImageView.kf.setImage(with: iconURL, placeholder: Constants.placeholderImage)
        }
    }
}

fileprivate extension UIViewController {
    func showAlert(withTitle title: String, message: String, okButtonTapped: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            okButtonTapped?()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

fileprivate extension Double {
    func fromDecimalToString() -> String {
        return String(format: "%.0f", self)
    }
}

fileprivate extension Constants {
    static let placeholderImage = UIImage(named: "no-image.png")
}
