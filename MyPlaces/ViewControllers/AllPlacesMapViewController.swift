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
    let annotationIdentifire = "annotetionID"

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        for place in places {
            mapManager.setupPlacemark(place: place, mapView: mapView)
        }
    }
}

extension AllPlacesMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifire) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
        }
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
        return annotationView
    }
}
