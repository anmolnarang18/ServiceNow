//
//  ViewController.swift
//  ServiceNow
//
//  Created by Anmol Narang on 14/04/23.
//

import UIKit
import CoreLocation
import SVProgressHUD
import Alamofire
import SwiftyJSON
import CoreData
import UserNotifications

class SplashVC: UIViewController ,CLLocationManagerDelegate{
    var locationManager:CLLocationManager!
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = .gray
        progressView.progressTintColor = UIColor(named: "ic_baseColor")
        return progressView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(progressView)
        progressView.frame = CGRect(x: 40, y: view.frame.size.height - 40, width: view.frame.size.width - 80, height: 15)
        locationSetup()
    }
    func locationSetup(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
            setupUI()
        }
        progressBar()
//        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
//        do{
//            try reachability.startNotifier()
//        }catch{
//            print("could not start reachability notifier")
//        }
    }
//    @objc func reachabilityChanged(note: Notification) {
//
//        let reachability = note.object as! Reachability
//
//        switch reachability.connection {
//        case .wifi:
//
//        case .cellular:
//            progressBar()
//            locationSetup()
//        case .unavailable:
//           showAlertMsg(Message: "Please check your network connection", AutoHide: false)
//        case .none:
//            SVProgressHUD.dismiss()
//            showAlertMsg(Message: "Please check your network connection", AutoHide: false)
//        }
//    }
    func progressBar(){
        for x in 0..<11{
            DispatchQueue.main.asyncAfter(deadline: .now()+(Double(x) * 0.50), execute: { [self] in
                progressView.setProgress(Float(x)/10, animated: true)
                if x == 10{
                    let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(vcStoreList, animated: true)
                }
            })
        }
        }
    @objc func setupUI(){
        
        if userlat == 0.0 && userlong == 0.0 {
            updatedCoordinates.latitude = LocationTracker.shared.currentLocationLatitude
            updatedCoordinates.longitude = LocationTracker.shared.currentLocationLongitude
            userlat = LocationTracker.shared.currentLocationLatitude
            userlong = LocationTracker.shared.currentLocationLongitude
            
        } else {
            updatedCoordinates.latitude = userlat
            updatedCoordinates.longitude = userlong
        }
        
//        if userlat != 0.0 && userlong != 0.0{
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        if userlat == 0.0 && userlong == 0.0 {
            updatedCoordinates.latitude = userLocation.coordinate.latitude
            updatedCoordinates.longitude = userLocation.coordinate.longitude
            userlat = userLocation.coordinate.latitude
            userlong = userLocation.coordinate.longitude
            
        } else {
            updatedCoordinates.latitude = userlat
            updatedCoordinates.longitude = userlong
        }
        
//        if userlat != 0.0 && userlong != 0.0{
//            timer.invalidate()
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }


}

