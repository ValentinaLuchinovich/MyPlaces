//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 27.11.2021.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var imageOfPlace: UIImageView! {
        didSet {
        imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
        imageOfPlace.clipsToBounds = true
        }
    }
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!

}

