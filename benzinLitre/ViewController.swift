//
//  ViewController.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let api = MyTaxiApi()
    
    var myTaxiList: [MyTaxi]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        api.fetchMyTaxiData{ response in
            if let data = response.data{
                self.myTaxiList = data
            }
        }
    }

}

