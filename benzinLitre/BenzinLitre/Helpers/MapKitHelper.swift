//
//  MapKitHelper.swift
//  benzinLitre
//
//  Created by omur olgunay on 21.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class MapKitHelper:NSObject, MKMapViewDelegate {
    
    let viewModel = BenzinLitreVM()
    var locationManager = LocationManagerHelper()
    var coordinateDic = [Int:(Double,Double)]()
    var annotationTitle = "Active"
    
    var infoLabel = UILabel()

    
    
    func addAnnotationToMap(map:MKMapView){
        map.delegate = self
        map.userTrackingMode = .follow
        
        viewModel.fetchBenzinLitreData { [weak self] in
            guard let strongSelf = self else { return }
            guard let list = strongSelf.viewModel.benzinLitreList else { return }
            for item in list{
                if let coordinate = item.coordinate{
                    guard let latitude = coordinate["latitude"], let longitude = coordinate["longitude"] else { return }
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    annotation.title = strongSelf.annotationTitle
                    if let driverId = item.id{
                        strongSelf.coordinateDic[driverId] = (latitude,longitude)
                        annotation.subtitle = "Driver ID: \(String(describing:driverId))"
                        annotation.title = String(driverId)
                    }
                    map.addAnnotation(annotation)
                    print(annotation)
                }
            }
        }
    }
    
    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }else{
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapKitHelper.callTapped))
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            av.rightCalloutAccessoryView!.addGestureRecognizer(tap)
            annotationView = av
        }
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "car")
        }
        
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let id = view.annotation?.title else { return }

        if let driverId = Int(id!){
            if let coordinate = self.coordinateDic[driverId]{
                self.locationManager.calculateDistanceFromGivenCordinate((coordinate.0, coordinate.1)) { (response) in
                    self.annotationTitle = response
                    let label = self.infoLabel
                    label.frame = CGRect(x: 0 , y: 0 , width: 200, height: 21)
                    label.textAlignment = .center
                    label.clipsToBounds = true
                    label.layer.cornerRadius = 5
                    label.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    label.font = UIFont.systemFont(ofSize: 13)
                    label.text = response
                    label.sizeToFit()
                    view.leftCalloutAccessoryView = label
                }
            }
        }
    }
    @objc func callTapped(){
        NotificationCenter.default.post(name:.callATaxi , object: nil)
    }
}
