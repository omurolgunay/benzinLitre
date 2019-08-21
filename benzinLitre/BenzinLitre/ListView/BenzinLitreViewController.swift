//
//  ViewController.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import UIKit

class BenzinLitreViewController: UIViewController{
    
    //MARK: - Variables
    let viewModel = BenzinLitreVM()
    var refreshControl = UIRefreshControl()
    var locationManager = LocationManagerHelper()    

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
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        benzinLitreTV.addSubview(refreshControl)
        // Notify when heading change
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .headingChange, object: nil)
    }

    @objc func refresh(){
        // Get taxi data
        viewModel.fetchBenzinLitreData { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.benzinLitreTV.reloadData()
            strongSelf.refreshControl.endRefreshing()
        }
    }
    @objc func reloadData(){
        guard let view = benzinLitreTV else { return }
        view.reloadData()
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
        if locationManager.arrowRotateDegreeArray.count > 0 {
            cell.arrowImage.transform =  CGAffineTransform(rotationAngle: CGFloat(locationManager.arrowRotateDegreeArray[indexPath.row].degreesToRadians()))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let benzinLitreList = viewModel.benzinLitreList {
            let item = benzinLitreList[indexPath.row]
            if let coordinate = item.coordinate{
                guard let latitude = coordinate["latitude"], let longitude = coordinate["longitude"] else { return }
                locationManager.calculateDistanceFromGivenCordinate((latitude, longitude)) { (response) in
                    print(response)
                }
            }
        }
    }
    
}
