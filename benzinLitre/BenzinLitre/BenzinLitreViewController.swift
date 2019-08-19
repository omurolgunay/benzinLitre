//
//  ViewController.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import UIKit

class BenzinLitreViewController: UIViewController {
    
    //MARK: - Variables
    let viewModel = BenzinLitreVM()
    
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
        viewModel.fetchBetbullData { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.benzinLitreTV.reloadData()
        }
    }

}

extension BenzinLitreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cellCount = viewModel.benzinLitreList?.count else { return 0}
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = benzinLitreTV.dequeueReusableCell(withIdentifier: BenzinLitreCell.identifier) as? BenzinLitreCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    
}
