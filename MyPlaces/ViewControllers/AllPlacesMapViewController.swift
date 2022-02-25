//
//  AllPlacesMapViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 25.02.2022.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class AllPlacesMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var places = realm.objects(Place.self)
    let mapManager = MapManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        for place in places {
            mapManager.setupPlacemark(place: place, mapView: mapView)
        }
    }

}
