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
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    
    override func loadView() {
        super.loadView()
        setupLocationManager()
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
        revGeocording(latitude: now_latitude!, longitude: now_longitude!)

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 35.7020691, longitude: 139.7753269)
        marker.title = "Tokyo"
        marker.snippet = "Japan"
        marker.map = mapView
    }

    func revGeocording(latitude: Double, longitude: Double)
    {
        let cur = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(cur, completionHandler: {(placemarks, error) -> Void in
            if (error == nil && placemarks!.count > 0) {
                let placemark = placemarks![0] as CLPlacemark
                var currentCity = ""
                
                if placemark.locality != nil {
                    currentCity = placemark.locality!
                    self.getArticles(currentcity: currentCity)
                }
            } else if (error == nil && placemarks!.count == 0) {
                
            } else if (error != nil) {
                
            }
        })
    }
    
    func getArticles(currentcity: String) {
        Alamofire.request("http://akachan.northbay.biz/town", method: .get, parameters: ["town_name": currentcity])
                 .responseJSON{ response in
                    print(response.result)
//                    let json = JSON(response.result.value)
//                    json["info"].forEach{(_, data) in
//                        let type = data["type"].string!
//                        print(type)
//                    }
        }
    }

}


