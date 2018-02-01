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

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var locationManager: CLLocationManager!
    let infoMarker = GMSMarker()
    
    override func loadView() {
        super.loadView()
        setupLocationManager()
    }
    
    func mapView(_ mapView:GMSMapView, didTapPOIWithPlaceID placeID:String,
                 name:String, location:CLLocationCoordinate2D) {
        //        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
        
        let button = UIButton()
        button.setTitle("この施設をみんなに共有する", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.sizeToFit()
        //        button.center = self.view.center
        button.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - 40)
        button.addTarget(self, action: #selector(ViewController.onClickMyButton(sender: )), for: .touchUpInside)
        self.view.addSubview(button)
        
        // 施設情報をUserDefaultsへ保存する
        let ud = UserDefaults.standard
        ud.set(location.latitude, forKey: "lat")
        ud.set(location.longitude, forKey: "long")
        ud.set(name, forKey: "name")
        
        infoMarker.snippet = placeID
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0;
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
    
    @objc func onClickMyButton(sender: UIButton) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "CreateFacility")
        present(nextView, animated: true, completion: nil)
        
        //        let ud = UserDefaults.standard
        //        print(ud.string(forKey: "name"))
        //        print(ud.string(forKey: "lat"))
        //        print(ud.string(forKey: "long"))
        
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
        getArticles(latitude: now_latitude!, longitude: now_longitude!) { response in
            response.forEach{(_, data) in
                let map_data = data as AnyObject?
                let map_position = CLLocationCoordinate2D(latitude: atof(map_data?["latitude"] as! String), longitude: atof(map_data?["longitude"] as! String))
                let spots = GMSMarker(position: map_position)
                spots.title = map_data?["title"] as! String
                spots.snippet = map_data?["snippet"] as! String
                spots.map = mapView
            }
            
        }
        
        // Creates a marker in the center of the map.
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
    
    func getArticles(latitude: Double, longitude: Double, apiResponse: @escaping (_ responseArticles: [String: Any]) -> ()){
        Alamofire.request("http://pasgroup:rem3shs3days@akachan.northbay.biz/town", parameters: ["lat": latitude,"lng": longitude])
            .responseJSON{ response in
                let json = JSON(response.result.value as Any)
                var spots_dictionary:[String:Any] = [:]
                
                json["data"].forEach{(_, data) in
                    var spot:[String:String] = [:]
                    
                    spot["title"] = data["facility_name"].string!
                    spot["snippet"] = data["facility_remark"].string!
                    spot["latitude"] = data["facility_lat"].string!
                    spot["longitude"] = data["facility_lng"].string!
                    
                    spots_dictionary[data["facility_name"].string!] = spot
                }
                apiResponse(spots_dictionary)
        }
    }
    
}


