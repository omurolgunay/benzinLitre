//
//  Double+Extension.swift
//  benzinLitre
//
//  Created by omur olgunay on 20.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import Foundation

extension Double {
    func degreesToRadians() -> Double {
        return self * .pi / 180.0
    }
    func radiansToDegrees() -> Double {
        return self * 180.0 / .pi
    }
}

