//
//  MyTaxiAPI.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class MyTaxiApi {
    
    func fetchMyTaxiData(completion: @escaping (MyTaxiResponse) -> Void) {
        let URL = "https://poi-api.mytaxi.com/PoiService/poi/v1?p2Lat=53.394655&p1Lon=9.757589&p1Lat=53.694865&p2Lon=10.099891"
        
        AF.request(URL).responseObject { [weak self] (response: DataResponse<MyTaxiResponse>) in
            guard let _ = self else { return }
            if let error = response.error {
                print("Failed to fetch data", error.localizedDescription)
                return
            }
            switch response.result {
            case let .success(value):
                completion(value)
            case let .failure(error):
                print(error)
            }
            
        }
    
    }
}
