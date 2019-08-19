//
//  BenzinLitreVM.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import Foundation

class BenzinLitreVM {
    let api = BenzinLitreApi()
    
    var benzinLitreList: [BenzinLitreData]? = nil
    
    func fetchBetbullData(completion: @escaping () -> Void){
        api.fetchBenzinLitreData { [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.benzinLitreList = response.data
            completion()
        }
    }
}
