//
//  CollectionViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 01.03.2022.
//

import UIKit

class DetailViewController: UIViewController {
    
    var currentPlace: Place?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataTransfer()
    }
    
    func dataTransfer() {
        guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
        placeImage.image = image
        placeImage.contentMode = .scaleAspectFill
        nameLabel.text = currentPlace?.name
        placeDescription.text = currentPlace?.myDescription
    }
}
