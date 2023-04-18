//
//  LocationTracker.swift
//  LocationTrackerWithCoreData28
//
//  Created by cl-mac-min-92 on 6/28/17.
//  Copyright © 2017 cl-mac-min-92. All rights reserved.
//
//  ****************** Version 1.0 ******************
//

import Foundation
import CoreLocation
import UIKit
import CoreData

typealias AuthorizationStatusHandler = ((_ status: CLAuthorizationStatus) -> Void)
typealias LocationTrackerHandler = ((_ location: CLLocation) -> Void)

enum AuthorizationType {
  case whenInUse
  case always
}

var currentLocationLatitude = CLLocationDegrees()
var currentLocationLongitude = CLLocationDegrees()
var firstTime = true
var fromSplash = true

class LocationTracker: NSObject {
  
  let horizontalAccuracy: Double = 20.0
    var currentLocationLatitude = CLLocationDegrees()
    var currentLocationLongitude = CLLocationDegrees()
    
  static let shared = LocationTracker(threshold: 9)
  fileprivate var locationManager: CLLocationManager?
  
  fileprivate var lastLocation: CLLocation?
  var lastSpeed: Double = 0.0
  var currentLocation: CLLocation? {
    return lastLocation
  }
  
  //Declare class instance property
  fileprivate var threshold: Double = 0.0
  
  //CallBacks
  fileprivate var authorizationStatusHandler: AuthorizationStatusHandler?
  fileprivate var locationTrackerHandler: LocationTrackerHandler?
  
  fileprivate var persistentStore: PersistentStoreLocation = PersistentStoreLocation()
  
  
  var  shareModel: LocationShareModel = LocationShareModel.sharedModel
  
  public init(threshold: Double, locationManager: CLLocationManager = CLLocationManager()) {
    super.init()
    self.threshold = threshold
    self.locationManager = locationManager
    self.locationManager?.delegate = self
    self.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    self.locationManager?.distanceFilter = 20
    self.locationManager?.requestWhenInUseAuthorization()
    self.locationManager?.startUpdatingLocation()
    
    // Get LastLocation
    self.lastLocation = self.persistentStore.getLastLocation()
    
    //
    NotificationCenter.default.addObserver(self, selector: #selector(LocationTracker.applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    
  }
  
  // MARK: - Public API
  public func didChangeAuthorizationStatus(callback: @escaping AuthorizationStatusHandler) {
    self.authorizationStatusHandler = callback
  }
  
  public func didChangeLocation(callback: @escaping LocationTrackerHandler) {
    self.locationTrackerHandler = callback
  }
  
  
  func startLocationTracker() {
    
    if #available(iOS 9.0, *) {
      locationManager?.allowsBackgroundLocationUpdates = false
    }
    
    locationManager?.startUpdatingLocation()
  }
  
  func stopLocationTracker() {
    
    if #available(iOS 9.0, *) {
      locationManager?.allowsBackgroundLocationUpdates = false
    }
    
    locationManager?.stopUpdatingLocation()
    self.shareModel.bgTask?.endBackgroundTasks()
    
  }
  
  
  // FIXME:- get speed task pending
  public func requestLocationWithAuthorization(type: AuthorizationType, callback: @escaping AuthorizationStatusHandler) {
    self.authorizationStatusHandler = callback
    let authorizationStatus =  CLLocationManager.authorizationStatus()
    switch type {
    case .always:
      if authorizationStatus != .authorizedAlways {
        self.locationManager?.requestAlwaysAuthorization()
      }
    case .whenInUse:
      if authorizationStatus != .authorizedWhenInUse {
        self.locationManager?.requestWhenInUseAuthorization()
      }
    }
  }
  
  public var locationServicesEnabled: Bool {
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
      case .notDetermined, .restricted, .denied, .authorizedAlways:
        return false
      case .authorizedWhenInUse:
        return true
      }
    }
    return false
  }
  
  // MARK: - Application State changed
  fileprivate func startBackGroundTask() {
    self.shareModel.bgTask = LocationBackgroundTaskManager.shared
    self.shareModel.bgTask?.beginNewBackgroundTask()
  }
  
  @objc private func applicationEnterBackground() {
    self.startBackGroundTask()
  }
  
  
  // function to open the Settings in app
  private func openSettings() {
    if #available(iOS 10.0, *) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
      }
    } else {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
      // Fallback on earlier versions
    }
  }
  
  //Show alert when case is denied
  fileprivate func showAlertForChangeAuthorization() {
//    UIAlertController.presentAlert(title: R.string.localizable.changeYourAuthorizationStatus(),
//                                   message: R.string.localizable.location_Authorization_Denied_Message(), style: UIAlertController.Style.alert).action(title: "Ok".localizedString, style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
//        if firstTime {
//            firstTime = false
//        NotificationCenter.default.post(name: Notification.Name.RedirectToMainScreen.redirectToMainScreen, object: nil)
//        }
//    })
  }
}

// MARK: - Store Presistent
extension LocationTracker {
  
  func removeAllLocalLocations(locations: [Location]) {
    self.persistentStore.removeObjects(list: locations)
  }
  
  func removeAllLocalLocations() {
    self.persistentStore.removeAllLocations()
  }
  
  func getSavedLocations(limit: Int = 0, ascending: Bool, callBack: @escaping (_ locations: [Location]) -> Void) {
    let list = self.persistentStore.getSavedLocations(limit: limit, ascending: ascending)
    callBack(list)
  }
  
}


// MARK: - CLLocationManagerDelegate
extension LocationTracker: CLLocationManagerDelegate {
  
    func configLocation(fromSplash: Bool) {
    locationManager = CLLocationManager()
    self.locationManager?.delegate = self
  }
    
  // TODO: didFailWithError
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Not Accessed \(error)")
  }
  
  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    switch status {
    case .notDetermined:
      self.locationManager?.requestWhenInUseAuthorization()
    case .authorizedWhenInUse, .authorizedAlways:
      self.startLocationTracker()
    case .restricted, .denied:
      self.stopLocationTracker()
      showAlertForChangeAuthorization()
    }
    authorizationStatusHandler?(status)
  }
  
  private func useAbleLocation(newLocation: CLLocation) {
    self.persistentStore.save(location: newLocation)
    self.locationTrackerHandler?(newLocation)
  }
  
  private func validLocation(location: CLLocation) -> Bool {
    let howRecent = location.timestamp.timeIntervalSinceNow
    guard CLLocationCoordinate2DIsValid(location.coordinate),
      location.horizontalAccuracy > 0,
      location.horizontalAccuracy < horizontalAccuracy,
      abs(howRecent) < 10 else { return false }
    return true
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last
    if let location = location {
    currentLocationLatitude = (location.coordinate.latitude)
    currentLocationLongitude = (location.coordinate.longitude)
    }
    }
}

// MARK: - Alert Controller
//extension UIAlertController {
//  
//  fileprivate func presentAlertController() {
//    UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
//  }
//  
//  @discardableResult
//    fileprivate class func showAlert(title: String?, message: String?, style: UIAlertController.Style) -> UIAlertController {
//    let alertController = UIAlertController.alert(title: title, message: message, style: style)
//    alertController.presentAlertController()
//    return alertController
//  }
//  
//}
