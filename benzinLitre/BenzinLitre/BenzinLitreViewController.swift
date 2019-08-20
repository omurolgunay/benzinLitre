//
//  ViewController.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import UIKit
import CoreLocation

class BenzinLitreViewController: UIViewController, CLLocationManagerDelegate{
    
    //MARK: - Variables
    let viewModel = BenzinLitreVM()
    let locationManager = CLLocationManager()
    var refreshControl = UIRefreshControl()
    var arrowRotateDegreeArray = [Double]()
    
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
        // Location Authorization
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        benzinLitreTV.addSubview(refreshControl)
        
        DispatchQueue.main.async {
            self.locationManager.delegate = self
            self.locationManager.headingFilter = 10.0
            self.locationManager.startUpdatingHeading()
        }
    }

    @objc func refresh(){
        // Get taxi data
        viewModel.fetchBenzinLitreData { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.benzinLitreTV.reloadData()
            strongSelf.refreshControl.endRefreshing()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
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
                self.arrowRotateDegreeArray.append(rotateDegree)
            }
        }
        print(arrowRotateDegreeArray)
        benzinLitreTV.reloadData()
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

}

//MARK:- TableView func
extension BenzinLitreViewController: UITableViewDelegate, UITableViewDataSource {
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
        if arrowRotateDegreeArray.count > 0 {
            cell.arrowImage.transform =  CGAffineTransform(rotationAngle: CGFloat(self.arrowRotateDegreeArray[indexPath.row].degreesToRadians()))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let benzinLitreList = viewModel.benzinLitreList {
            let item = benzinLitreList[indexPath.row]
            if let coordinate = item.coordinate{
                guard let latitude = coordinate["latitude"], let longitude = coordinate["longitude"] else { return }
                viewModel.calculateDistanceFromGivenCordinate((latitude, longitude)) { (response) in
                    print(response)
                }
            }
        }
    }
    
}
