//
//  BenzinLitreVM.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class BenzinLitreVM {
    //MARK:- Variables
    let api = BenzinLitreApi()
    var benzinLitreList: [BenzinLitreData]? = nil
    
    
    func fetchBetbullData(completion: @escaping () -> Void){
        api.fetchBenzinLitreData { [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.benzinLitreList = response.data
            completion()
        }
    }
    
    //Get current location and calculate the distance from selected car
    func calculateDistanceFromGivenCordinate(_ cordinate: (Double,Double), completion: @escaping (String) -> Void ) {
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
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
