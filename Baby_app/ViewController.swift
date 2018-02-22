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

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
print("You tapped")
        
        let button = UIButton()
        button.setTitle("この施設をオススメする", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.sizeToFit()
        button.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - 40)
        button.addTarget(self, action: #selector(ViewController.onClickMyButton(sender: )), for: .touchUpInside)
        self.view.addSubview(button)
        
        // 施設情報をUserDefaultsへ保存する
        let ud = UserDefaults.standard
        ud.set(marker.title!, forKey: "name")
        
        infoMarker.snippet = placeID
        infoMarker.position = location
        infoMarker.title = marker.title!
        infoMarker.opacity = 0;
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
        return false
    }

//    func () -> UIView? {
//        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 300, height: 300))
//        view.backgroundColor = UIColor.white
//        view.layer.cornerRadius = 6
//
//        let lbl1 = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 15))
//        lbl1.text = marker.title!
//        view.addSubview(lbl1)
//
//        let lbl2 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
//        lbl2.text = marker.snippet!
//        lbl2.font = UIFont.systemFont(ofSize: 14, weight: .light)
//        view.addSubview(lbl2)
//
//        let lbl3 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + lbl2.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
//        lbl3.text = ""
//        lbl3.font = UIFont.systemFont(ofSize: 14, weight: .light)
//        view.addSubview(lbl3)
//
//        let lbl4: UITextField = UITextField()
//        lbl4.frame = CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + lbl2.frame.size.height + lbl3.frame.size.height + 5, width: view.frame.size.width - 16, height: 90)
//        lbl4.text = "口コミを入力してください"
//        lbl4.font = UIFont.systemFont(ofSize: 14, weight: .light)
//        lbl4.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
//        lbl4.layer.borderWidth = 1
//        view.addSubview(lbl4)
//
//        let lbl5 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + lbl2.frame.size.height + lbl3.frame.size.height + lbl4.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
//        lbl5.text = "この施設の評価を送信する"
//        lbl5.font = UIFont.systemFont(ofSize: 14, weight: .light)
//        view.addSubview(lbl5)
//
//        return view
//    }

    
    @objc func onClickMyButton(sender: UIButton) {
        performSegue(withIdentifier: "modal", sender: nil)
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 1000
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
        mapView.delegate = self
        view = mapView
        getArticles(latitude: now_latitude!, longitude: now_longitude!) { response in
            response.forEach{(_, data) in
                let map_data = data as AnyObject?
                let map_position = CLLocationCoordinate2D(latitude: atof(map_data?["latitude"] as! String), longitude: atof(map_data?["longitude"] as! String))
                let spots = GMSMarker(position: map_position)
                spots.title = map_data?["title"] as? String
                spots.snippet = map_data?["snippet"] as? String
                spots.map = mapView

            }
            
        }
        
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


