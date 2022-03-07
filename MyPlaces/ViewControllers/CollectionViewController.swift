//
//  CollectionViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 01.03.2022.
//

import UIKit
import RealmSwift

class CollectionViewController: UIViewController {

    private var places: Results<Place>!
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
}

// MARK: Data Sourse / Delegate

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! CustomCollectionViewCell
        cell.layer.cornerRadius = cell.photoImage.frame.size.height / 2
        cell.contentMode = .scaleAspectFill
        cell.photoImage.clipsToBounds = true
        cell.photoImage.image = UIImage(data: places[indexPath.row].imageData!)
        return cell
    }
    
    // Переход по нажатию на DetailVC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            let place = places[indexPath.row]
            detailViewController.currentPlace = place
            present(detailViewController, animated: true, completion: nil)
        }
    }
}
