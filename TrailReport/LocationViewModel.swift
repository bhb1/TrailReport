//
//  LocationViewModel.swift
//  TrailReport
//
//  Created by Braden Becker on 12/9/23.
//
//  Based on the tutorial at: https://mobileinvader.com/corelocation-in-swiftui-mvvm-unit-tests/
//


import Foundation
import Combine
import CoreLocation

class LocationViewModel: NSObject, ObservableObject{
    @Published var userLatitude: Double = 0
    @Published var userLongitude: Double = 0
  
    @Published var duration: TimeInterval = 0
    @Published var distance: Double = 0
   
    @Published var points: [CLLocation] = []
    @Published var filteredPoints: [CLLocation] = []
    
    @Published var filterDistance: Int
    @Published var uploadURL: URL
    @Published var deviceID: Int
       
    
    private let locationManager = CLLocationManager()
    
    var live: Bool = false
    
    func reset(){
        self.distance = 0.0
        self.points = []
        self.filteredPoints = []
        
    }
    
  override init() {
    self.filterDistance = UserDefaults.standard.object(forKey: "filterDistance") as? Int ?? 5
    self.uploadURL = UserDefaults.standard.object(forKey: "uploadURL") as? URL ?? URL(string: "https://b9ac252e833b4afa399912e731d0da49.m.pipedream.net")!
    self.deviceID = UserDefaults.standard.object(forKey: "deviceID") as? Int ?? 12347
    
    super.init()

    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.startUpdatingLocation()
    print(locationManager.authorizationStatus.rawValue.description)
    switch locationManager.authorizationStatus {
              case .notDetermined:
                  print("When user did not yet determined")
              case .restricted:
                  print("Restricted by parental control")
              case .denied:
                  print("When user select option Dont't Allow")
              case .authorizedWhenInUse:
                  print("When user select option Allow While Using App or Allow Once")
              default:
                  print("default")
              }

  }
}

extension LocationViewModel: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    userLatitude = location.coordinate.latitude
    userLongitude = location.coordinate.longitude
   
    
    //Check for status
    if (live) {
        print(filterDistance)
        //Check that there exists a point to measure off of
        if (filteredPoints.count == 0) {
            //Points is empty, append point
            filteredPoints.append(location)
        
        //Points is not empty, check the distance before adding
        } else {
            let delta = location.distance(from: filteredPoints.last!)
            
            if (delta > Double(filterDistance) ) {
                filteredPoints.append(location)
                self.distance += delta
            }
        }
        
        //Add location at the end to compare to next time
        points.append(location)

    }
   //userLatitude = points.last?.coordinate.latitude
   // userLatitude = points.last?.coordinate.latitude
    
    
  }
}
