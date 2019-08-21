//
//  TimeInterval+Extension.swift
//  benzinLitre
//
//  Created by omur olgunay on 20.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import Foundation

extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        if hours == 0{
            return String(format: "%0.2d minutes away",minutes)
        }else{
            return String(format: "%0.2d hours %0.2d minutes away",hours,minutes)
        }
    }
}
