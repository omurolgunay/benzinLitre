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
        // TODO: implementation the call taxi logic
        print("Taxi Called")
    }

}
