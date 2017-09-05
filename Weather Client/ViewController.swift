//
//  ViewController.swift
//  Weather Client
//
//  Created by anna on 04.09.17.
//  Copyright © 2017 anna. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var zoomSlider: UISlider!
    @IBOutlet weak var cityDetailsView: UIView!
    @IBOutlet weak var verticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    let initialCoordinate = (latitude: 34.1, longitude: -118.2)
    let initialSpan = 20.0
    let verticalConstants = (verticalShowConstant: 16.0, verticalHideConstant: -120.0)
    let weatherSegueIdentifier = "ShowWeather"
    
    var currentCity: CLPlacemark? {
        didSet {
            //update labels
            cityLabel.text = currentCity!.locality
            cityLabel.text = cityLabel.text! + "\nLatitude: \(currentCity!.location!.coordinate.latitude)"
            cityLabel.text = cityLabel.text! + "\nLongitude: \(currentCity!.location!.coordinate.longitude)"
            
            //if cityDetailsView is hidden, show it and update constraints
            if cityDetailsView.isHidden {
                verticalConstraint.constant = CGFloat(verticalConstants.verticalShowConstant)
                UIView.animate(withDuration: 0.5){ [weak self] in
                    self?.cityDetailsView.isHidden = false
                    self?.view.layoutIfNeeded() //tell the view to layout again
                }
            }
        }
    }
    
    
    
    func setZoom(_ coordinate: CLLocationCoordinate2D? = nil) {
        var currentCoordinate = coordinate
        if currentCoordinate == nil {
            currentCoordinate = mapView.centerCoordinate
        }
        let zoom = Double(zoomSlider.value)
        let span = MKCoordinateSpanMake(zoom, zoom)
        let region = MKCoordinateRegionMake(currentCoordinate!, span)
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set zoomSlider defaults
        zoomSlider.minimumValue = 1.0
        zoomSlider.maximumValue = 100.0
        zoomSlider.value = Float(initialSpan)
        
        //focus mapView in initial coordinates
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: initialCoordinate.latitude, longitude: initialCoordinate.longitude)
        setZoom(coordinate)
        
        //add handler for tap gesture (for defining tap coordinates in map view)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(byReactingTo:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        cityDetailsView.isHidden = true
        verticalConstraint.constant = CGFloat(verticalConstants.verticalHideConstant)
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded() //tell the view to layout again
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
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        setZoom()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            identifier == weatherSegueIdentifier,
            let vc = segue.destination as? WeatherViewController {
            vc.city = currentCity
        }
    }
}

