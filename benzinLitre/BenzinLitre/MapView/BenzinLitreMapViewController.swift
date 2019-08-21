//
//  BenzinLitreMapViewController.swift
//  benzinLitre
//
//  Created by omur olgunay on 21.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import UIKit
import MapKit

class BenzinLitreMapViewController: UIViewController {
    
    //MARK: - Variables
    let mapKitHelper = MapKitHelper()
    //MARK: - IBOutlets
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - IBActions

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: .callATaxi, object: nil)
        mapKitHelper.addAnnotationToMap(map: map)
    }
    @objc func showAlert(){

        let alert = UIAlertController(title: "Call a Taxi", message: "You want to call this taxi?", preferredStyle: .alert)
        let yesAction =  UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) in UIApplication.shared.openURL(URL(string: "tel://05342647278")!)})
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }

}
