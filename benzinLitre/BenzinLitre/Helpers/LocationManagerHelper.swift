//
//  LocationManager.swift
//  benzinLitre
//
//  Created by omur olgunay on 21.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationManagerHelper: NSObject, CLLocationManagerDelegate  {
    
    let locationManager = CLLocationManager()
    var arrowRotateDegreeArray = [Double]()
    let viewModel = BenzinLitreVM()

    override init() {
        super.init();
        self.locationManager.delegate = self;

        // Get taxi data
        viewModel.fetchBenzinLitreData {}
    
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // Location Authorization
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
        }
        // Start Updating Heading for calculateImageTransformDegree
        DispatchQueue.main.async {
            self.locationManager.delegate = self
            self.locationManager.headingFilter = 10.0
            self.locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let heading = self.locationManager.heading{
            self.calculateImageTransformDegree(manager: self.locationManager, newHeading: heading )
            NotificationCenter.default.post(name: .headingChange, object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        calculateImageTransformDegree(manager: manager, newHeading: newHeading)
        NotificationCenter.default.post(name: .headingChange, object: nil)
    }
    
    func getBearingBetweenTwoCoordinate(point1 : CLLocation, point2 : CLLocation) -> Double {
        let latitude1 = point1.coordinate.latitude.degreesToRadians()
        let longitude1 = point1.coordinate.longitude.degreesToRadians()
        
        let latitude2 = point2.coordinate.latitude.degreesToRadians()
        let longitude2 = point2.coordinate.longitude.degreesToRadians()
        
        let dLon = longitude2 - longitude1
        let y = sin(dLon) * cos(latitude2)
        let x = cos(latitude1) * sin(latitude2) - sin(latitude1) * cos(latitude2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansBearing.radiansToDegrees()
    }
    
    func calculateImageTransformDegree(manager: CLLocationManager, newHeading: CLHeading) {
        self.arrowRotateDegreeArray.removeAll()
        if CLLocationManager.locationServicesEnabled() {
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
        }
        guard let userLatitude = manager.location?.coordinate.latitude, let userLongitude = manager.location?.coordinate.longitude else { return }
        guard let list = viewModel.benzinLitreList else { return }
        // User location
        let coordinate1 = CLLocation(latitude: userLatitude, longitude:userLongitude)
        
        for item in list {
            if let coordinate = item.coordinate{
                guard let latitude = coordinate["latitude"], let longitude = coordinate["longitude"] else { return }
                // Taxi location
                let coordinate2 = CLLocation(latitude: latitude, longitude: longitude)
                var rotateDegree = getBearingBetweenTwoCoordinate(point1: coordinate1, point2: coordinate2) - newHeading.trueHeading
                if rotateDegree < 0 {
                    rotateDegree += 360
                }
                self.arrowRotateDegreeArray.append(rotateDegree - 180)
            }
        }
    }
    
    
    //Get current location and calculate the distance from selected car
    func calculateDistanceFromGivenCordinate(_ cordinate: (Double,Double), completion: @escaping (String) -> Void ) {
        let locationManager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        guard let userLatitude = locationManager.location?.coordinate.latitude, let userLongitude = locationManager.location?.coordinate.longitude else { return }
        // User location
        let coordinate1 = CLLocation(latitude: userLatitude, longitude: userLongitude)
        // veichle location
        let coordinate2 = CLLocation(latitude: cordinate.0, longitude: cordinate.1)
        self.getDirectionEtaForTwoCordinate(userCoordinate: coordinate1, taxiCoordinate: coordinate2, completion: { (response) in
            completion(response)
        })
    }
    
    func getDirectionEtaForTwoCordinate(userCoordinate: CLLocation, taxiCoordinate:CLLocation, completion: @escaping (String) -> Void) {
        var stringTime = "Calculating Error"
        let mapItemUser = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate.coordinate))
        let mapItemTaxi = MKMapItem(placemark: MKPlacemark(coordinate: taxiCoordinate.coordinate))
        // Direction request for displaying estimating waiting time for taxi
        let directionRequest = MKDirections.Request()
        // Taxi coming for user, source is taxi for that reason
        directionRequest.source = mapItemTaxi
        directionRequest.destination = mapItemUser
        directionRequest.transportType = .automobile
        
        let direction = MKDirections(request: directionRequest)
        // Calculate Estimating Time for taxi
        direction.calculateETA { (response, error) in
            guard error == nil, let response = response else {return}
            stringTime = response.expectedTravelTime.stringFromTimeInterval()
            completion(stringTime)
        }
    }
}
