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

}

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        <#code#>
    }
}
