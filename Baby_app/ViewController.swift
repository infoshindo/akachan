//
//  ViewController.swift
//  Baby_app
//
//  Created by 堀内慶 on 2017/10/31.
//  Copyright © 2017年 堀内慶. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var locationManager: CLLocationManager!
    let infoMarker = GMSMarker()
    
    override func loadView() {
        super.loadView()
        setupLocationManager()
        
    }
    
    func mapView(_ mapView:GMSMapView, didTapPOIWithPlaceID placeID:String,
                 name:String, location:CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
        
        infoMarker.snippet = placeID
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0;
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let now_latitude = location?.coordinate.latitude
        let now_longitude = location?.coordinate.longitude
        
        
        // Create a GMSCameraPosition that tells the map to display the
        let camera = GMSCameraPosition.camera(withLatitude: now_latitude!, longitude: now_longitude!, zoom: 17.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        view = mapView
//        setupLocationManager()
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498)
        marker.title = "Tokyo"
        marker.snippet = "Japan"
        marker.map = mapView
        
        
        let position = CLLocationCoordinate2D(latitude:35.700707, longitude: 139.775183)
        let akiba = GMSMarker(position: position)
        akiba.title = "秋葉原"
        akiba.snippet = "あああああ"
        akiba.map = mapView
        
        
        _ = GMSCameraPosition.camera(withLatitude:47.603,
                                              longitude:-122.331,
                                              zoom:14)
        _ = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        self.view = mapView
    }

    func revGeocording(coordinate: CLLocationCoordinate2D)
    {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if (error == nil && placemarks!.count > 0) {
                let placemark = placemarks![0] as CLPlacemark
                var currentCity = ""
                
                if placemark.locality != nil {
                    currentCity = placemark.locality!
                    print(currentCity)
                }
            } else if (error == nil && placemarks!.count == 0) {
                
            } else if (error != nil) {
                
            }
        })
    }
    

}


