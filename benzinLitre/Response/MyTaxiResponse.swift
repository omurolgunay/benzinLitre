//
//  MyTaxiResponse.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//
/*
 
 {
     "id": -1800837557,
     "coordinate": {
     "latitude": 53.56380264821218,
     "longitude": 9.990385361015797
     },
     "state": "ACTIVE",
     "type": "TAXI",
     "heading": 84.27156829833984
 },
 
 */
import Foundation
import ObjectMapper

class MyTaxiResponse: Mappable {
    
    var data: [MyTaxi]?

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        data <- map["poiList"]
    }
}

class MyTaxi: Mappable {
    var id: Int?
    var cordinate: Dictionary<Double,Double>?
    var state: String?
    var type: String?
    var heading: Double?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        cordinate <- map["cordinate"]
        state <- map["state"]
        type <- map["type"]
        heading <- map["heading"]
    }
}
