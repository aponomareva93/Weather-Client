//
//  MapViewController.swift
//  Weather Client
//
//  Created by anna on 07.09.17.
//  Copyright © 2017 anna. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var cityDetailsView: UIView!
    @IBOutlet private weak var verticalConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cityLabel: UILabel!

    private let locationManager = CLLocationManager()

    private var currentCity: CLPlacemark? {
        didSet {
            cityLabel.text = currentCity!.locality
            cityLabel.text = cityLabel.text! +
            "\nLatitude: \(currentCity!.location!.coordinate.latitude)"
            cityLabel.text = cityLabel.text! +
            "\nLongitude: \(currentCity!.location!.coordinate.longitude)"

            if cityDetailsView.isHidden {
                verticalConstraint.constant = Constants.cityDetailsViewTopOffset
                UIView.animate(withDuration:
                Constants.cityDetailsViewAnimationDuaration) { [weak self] in
                    self?.cityDetailsView.isHidden = false
                    self?.view.layoutIfNeeded()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let coordinate: CLLocationCoordinate2D =
            CLLocationCoordinate2D (latitude: Constants.initialLatitude,
                                    longitude: Constants.initialLongitude)
        let span = MKCoordinateSpanMake(Constants.initialSpan, Constants.initialSpan)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: true)

        let tapGestureRecognizer =
            UITapGestureRecognizer(target: self,
                                   action: #selector(tapHandler(byReactingTo:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGestureRecognizer)

        cityDetailsView.isHidden = true
        verticalConstraint.constant = Constants.cityDetailsViewTopOffsetForHiding
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    func tapHandler(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        let tapLocation = tapRecognizer.location(in: mapView)
        let coordinate = mapView.convert(tapLocation, toCoordinateFrom: mapView)

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        CLGeocoder().reverseGeocodeLocation(location,
                                            completionHandler: {
                                                [weak self] (placemarks, error) in
                                                if let error = error {
                                                    print(error.localizedDescription)
                                                } else if let placemark = placemarks?[0],
                                                    placemark.locality != nil {
                                                    self?.currentCity = placemark
                                                }
            }
        )
    }

    @IBAction private func showWeather(_ sender: UIButton) {
        let weatherViewController =
            WeatherViewController(city: currentCity)
        navigationController?.pushViewController(weatherViewController, animated: true)
    }
}

fileprivate extension Constants {
    static let initialLatitude: CLLocationDegrees = 34.1
    static let initialLongitude: CLLocationDegrees = -118.2
    static let initialSpan: CLLocationDegrees = 20.0
    static let cityDetailsViewTopOffset: CGFloat = 33.0
    static let cityDetailsViewTopOffsetForHiding: CGFloat = -120.0
    static let cityDetailsViewAnimationDuaration: TimeInterval = 0.5
}
