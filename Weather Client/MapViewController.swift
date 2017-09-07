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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cityDetailsView: UIView!
    @IBOutlet weak var verticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    let initialCoordinate = (latitude: 34.1, longitude: -118.2)
    let initialSpan = 20.0
    let verticalConstants = (verticalShowConstant: 41.0, verticalHideConstant: -120.0)
    let weatherSegueIdentifier = "ShowWeather"
    
    var currentCity: CLPlacemark? {
        didSet {
            cityLabel.text = currentCity!.locality
            cityLabel.text = cityLabel.text! + "\nLatitude: \(currentCity!.location!.coordinate.latitude)"
            cityLabel.text = cityLabel.text! + "\nLongitude: \(currentCity!.location!.coordinate.longitude)"
            
            if cityDetailsView.isHidden {
                verticalConstraint.constant = CGFloat(verticalConstants.verticalShowConstant)
                UIView.animate(withDuration: 0.5){ [weak self] in
                    self?.cityDetailsView.isHidden = false
                    self?.view.layoutIfNeeded()
                }
            }
        }
    }
    
    override func loadView() {
        if let array = Bundle.main.loadNibNamed("MapViewController", owner: self, options: nil) {
            if array.count > 0 {
                self.view = array[0] as? UIView
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: initialCoordinate.latitude, longitude: initialCoordinate.longitude)
        let span = MKCoordinateSpanMake(initialSpan, initialSpan)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(byReactingTo:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        cityDetailsView.isHidden = true
        verticalConstraint.constant = CGFloat(verticalConstants.verticalHideConstant)
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
    }
    
    func tapHandler(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        let tapLocation = tapRecognizer.location(in: mapView)
        let coordinate = mapView.convert(tapLocation,toCoordinateFrom: mapView)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {  [weak self] (placemarks, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else if let placemark = placemarks?[0],
                placemark.locality != nil {
                self?.currentCity = placemark
            }
        })
    }

    @IBAction func showWeather(_ sender: UIButton) {
        let weatherViewController = WeatherViewController(nibName: "WeatherViewController", bundle: nil)
        weatherViewController.city = currentCity
        navigationController?.pushViewController(weatherViewController, animated: true)
    }
    

}
