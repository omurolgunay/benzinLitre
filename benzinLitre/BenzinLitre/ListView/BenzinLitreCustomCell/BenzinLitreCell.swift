//
//  BenzinLitreCell.swift
//  benzinLitre
//
//  Created by omur olgunay on 19.08.2019.
//  Copyright © 2019 omur olgunay. All rights reserved.
//

import UIKit

class BenzinLitreCell: UITableViewCell {
    
    //MARK:- Variables
    static let identifier = "BenzinLitreCell"
    static let estimatedRowHeight: CGFloat = 96
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var stateLabel: UILabel!{
        didSet{
            self.stateLabel.clipsToBounds = true
            self.stateLabel.layer.cornerRadius = 3
        }
    }
    @IBOutlet weak var typeLabel: UILabel!{
        didSet{
            self.typeLabel.clipsToBounds = true
            self.typeLabel.layer.cornerRadius = 3
        }
    }
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(benzinLitreItem item: BenzinLitreData){
        stateLabel.text = item.state
        typeLabel.text = item.type
        idLabel.text = String(item.id!)
    }
    
}
