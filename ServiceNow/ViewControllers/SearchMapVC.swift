//
//  MapVC.swift
//  My Trolly
//
//  Created by Bhadresh Sorathiya on 24/04/20.
//  Copyright © 2020 wos_Mitesh. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import CoreLocation
import GooglePlaces

protocol UpdateLocationDelegate {
    func sendUpdateLocation(address: String)
}

var currentCoordinates: CLLocationCoordinate2D?

class SearchMapVC: UIViewController {
    
    //MARK: Outlet
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBOutlet weak var markerImage: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currentBtn: UIButton!
    @IBOutlet weak var locationLabel: UILabel!{
        didSet {
            locationLabel.font.withSize(CGFloat(12))
        }
    }
    
    //MARK: Variable
    var isMianScreen = false
    var addressString = ""
    var latitude = 0.0
    var longitude = 0.0
    var locationManager = CLLocationManager()
    var searchCallBack: ((Double, Double, String, Bool) -> Void)?
    
    var delegate: UpdateLocationDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMSServices.provideAPIKey(Keys.gmsPlacesClientKey)
        GMSPlacesClient.provideAPIKey(Keys.gmsPlacesClientKey)
        
        roundCorners(view: submitButton, corners: [.topLeft,.topRight], radius: 5)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        mapView.bringSubviewToFront(markerImage)
        mapView.bringSubviewToFront(submitButton)
        mapView.bringSubviewToFront(backButton)
        mapView.bringSubviewToFront(currentBtn)
        self.addMapView()
        
    }
    
    //MARK: BackButton
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Get Current Location
    @IBAction func currentLocation(_ sender: UIButton) {
        let initialLocation: CLLocationCoordinate2D?
        initialLocation = CLLocationCoordinate2D(latitude: LocationTracker.shared.currentLocationLatitude, longitude: LocationTracker.shared.currentLocationLongitude)
        if let initialLocation = initialLocation {
            setUpMap(coordinates: initialLocation)
        }
    }
    
    //MARK: Submit Action
    @IBAction func submitAction(_ sender: UIButton) {
        if let callBack = searchCallBack {
            callBack(latitude, longitude, addressString, isMianScreen)
            //self.delegate?.sendUpdateLocation(address: addressString)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onSearchLocation(_ sender: Any) {
        let addressVC = GMSAutocompleteViewController()
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        addressVC.autocompleteFilter = filter
        addressVC.delegate = self
        self.present(addressVC,animated: true,completion: nil)
    }
}

extension SearchMapVC: GMSMapViewDelegate {
    // MARK: - Add MapView
    func addMapView() {
        let initialLocation: CLLocationCoordinate2D?
        initialLocation = CLLocationCoordinate2D(latitude: userlat, longitude: userlong)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        if let initialLocation = initialLocation {
            setUpMap(coordinates: initialLocation)
        }
        
    }
    
    // MARK : SetUp Map View
    func setUpMap(coordinates: CLLocationCoordinate2D?) {
        var camera: GMSCameraPosition?
        if let coordinates = coordinates {
            camera = GMSCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: 16.0)
        }
        currentCoordinates = coordinates
        if let camera = camera {
            mapView.camera = camera
        }
        mapView.isMyLocationEnabled = false
        mapView.delegate = self
    }
    
    
    // MARK: - MapViewDelegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        var updatedCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
        userlat = position.target.latitude
        userlong = position.target.longitude
        
//        let language = Localize.currentLang()
//        var lang = localLanguage
//        if language == .arabic {
//            lang = localLanguage
//        }
        let url =  "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(userlat),\(userlong)&key=\(Keys.googleKey)&language=en&sensor=true"
        
        TrackOrderModel.sendRequestToServer(baseUrl: url, "", httpMethod: "POST", isZipped: false) { (isSuccess, response) in
            if let address = response["results"] as? [[String: Any]], let data = address.first, let formatedAddess = data["formatted_address"] as? String {
                if let geoData = data["geometry"] as? [String: Any], let location = geoData["location"] as? [String: Any], let lat = location["lat"] as? Double, let long = location["lng"] as? Double {
                    self.latitude = lat
                    self.longitude = long
                }
                self.addressString = formatedAddess
                DispatchQueue.main.async {
                    self.locationLabel.text = formatedAddess
                }
            }
        }
    }
    
    // MARK: - Api call
    func reverseGeocode(locationCoordinates: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(locationCoordinates) { [weak self]response, error in
            if let address = response?.firstResult() {
                guard self != nil else {
                    return
                }
                self?.latitude = address.coordinate.latitude
                self?.longitude = address.coordinate.longitude
                if let lines = address.lines {
                    self?.addressString = lines.joined(separator: " ")
                    //self?.address.text = lines.joined(separator: " ")
                }
            }
        }
    }
    
    
    
}

// MARK: LocationManager Delegate
extension SearchMapVC: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (manager.location?.coordinate) != nil {
            if let currentLocation = locations.first?.coordinate {
                currentCoordinates = currentLocation
                self.setUpMap(coordinates: currentLocation)
            }
            locationManager.stopUpdatingLocation()
        }
    }
}

extension SearchMapVC: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        userlat = place.coordinate.latitude
        userlong = place.coordinate.longitude
        setUpMap(coordinates: place.coordinate)
        locationLabel.text = place.formattedAddress
        self.dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
