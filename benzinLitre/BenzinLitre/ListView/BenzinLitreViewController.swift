//
//  ViewController.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import UIKit
import SwiftEntryKit
import MapKit

class BenzinLitreViewController: UIViewController{
    
    //MARK: - Variables
    let viewModel = BenzinLitreVM()
    var refreshControl = UIRefreshControl()
    var locationManager = LocationManagerHelper()    

    //MARK: - IBOutlets
    @IBOutlet weak var benzinLitreTV: UITableView!{
        didSet{
            benzinLitreTV.register(UINib(nibName: String(describing: BenzinLitreCell.self), bundle: nil), forCellReuseIdentifier: BenzinLitreCell.identifier)
            benzinLitreTV.delegate = self
            benzinLitreTV.dataSource = self
            benzinLitreTV.estimatedRowHeight = BenzinLitreCell.estimatedRowHeight
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        benzinLitreTV.addSubview(refreshControl)
        // Notify when heading change
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .headingChange, object: nil)
    }

    @objc func refresh(){
        // Get taxi data
        viewModel.fetchBenzinLitreData { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.benzinLitreTV.reloadData()
            strongSelf.refreshControl.endRefreshing()
        }
    }
    
    @objc func reloadData(){
        guard let view = benzinLitreTV else { return }
        view.reloadData()
    }
}

//MARK:- TableView func
extension BenzinLitreViewController: UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cellCount = viewModel.benzinLitreList?.count else { return 0}
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = benzinLitreTV.dequeueReusableCell(withIdentifier: BenzinLitreCell.identifier) as? BenzinLitreCell else {
            return UITableViewCell()
        }
        if let benzinLitreList = viewModel.benzinLitreList {
            let benzinLitreItem = benzinLitreList[indexPath.row]
            guard let _ = benzinLitreItem.id else { return UITableViewCell() }
            cell.configureCell(benzinLitreItem: benzinLitreItem)
        }
        if locationManager.arrowRotateDegreeArray.count > 0 {
            // Rotate the arrow image according to user heading for pointing the veichle
            cell.arrowImage.transform =  CGAffineTransform(rotationAngle: CGFloat(locationManager.arrowRotateDegreeArray[indexPath.row].degreesToRadians()))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let benzinLitreList = viewModel.benzinLitreList {
            let item = benzinLitreList[indexPath.row]
            if let coordinate = item.coordinate{
                guard let latitude = coordinate["latitude"], let longitude = coordinate["longitude"] else { return }

                if let customView = Bundle.main.loadNibNamed("PopUpCustomView", owner: self, options: nil)!.first as? PopUpCustomView {
                    // Add annotation
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    annotation.title = "Call This Taxi"
                    customView.map.delegate = self
                    customView.restorationIdentifier = "PopUpCustomView"
                    customView.map.userTrackingMode = .followWithHeading
                    customView.map.addAnnotation(annotation)
                    customView.layer.cornerRadius = 10
                    customView.clipsToBounds = true
                    locationManager.calculateDistanceFromGivenCordinate((latitude, longitude)) { (response) in
                        customView.estimatedTimeLabel.text = response
                    }

                    // Create a basic toast that appears at the top
                    var attributes = EKAttributes.centerFloat
                    attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
                    attributes.positionConstraints.size.height = .constant(value: 250)
                    attributes.entryBackground = .color(color: .white)
                    attributes.entryInteraction = .absorbTouches
                    attributes.entranceAnimation = .translation
                    attributes.exitAnimation = .translation
                    attributes.screenInteraction = .dismiss
                    attributes.displayDuration = .infinity
                    attributes.lifecycleEvents.willDisappear = {
                        // Remove all annotation before popUp closed it caused crash (SwiftEntryKit)
                        let allAnnotation = customView.map.annotations
                        customView.map.removeAnnotations(allAnnotation)
                    }
                    // Display the view with the configuration
                    SwiftEntryKit.display(entry: customView, using: attributes)
                }
            }
        }
    }
    //TODO: Organize here
    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Check for is this customer annotation
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }else{
            // Adding call button for annotationView and the gesture
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.callTapped))
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            av.rightCalloutAccessoryView!.addGestureRecognizer(tap)
            annotationView = av
        }
        // Adding custom image for annotationView (Benzin litre custom image)
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "car")
        }
        return annotationView
    }
    @objc func callTapped() {
        // TODO: implementation the call taxi logic
        print("Taxi called")
    }
}
