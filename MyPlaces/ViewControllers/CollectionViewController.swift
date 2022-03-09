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
    let insents = UIEdgeInsets(top: 0, left: 10, bottom: 50, right: 10)
    let itemsPerRow: CGFloat = 3 //Коллчичество ячеек в ряду
    let sectionInserts = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20) //Отсупы
    
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
        cell.layer.cornerRadius = cell.frame.size.height / 2
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

// MARK: FlowLayout

extension CollectionViewController: UICollectionViewDelegateFlowLayout {

    //Размер ячеек
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let peddingWidth = sectionInserts.left * (itemsPerRow + 1)
    let availableWidth = collectionView.frame.width - peddingWidth
    let widthPerItem = availableWidth / itemsPerRow
    return CGSize(width: widthPerItem, height: widthPerItem)
}
    
    //Границы для ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInserts
    }

    //Отсупы между линиями
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInserts.left
    }

    //Растояние между самими объектами
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInserts.left
    }
}
