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

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {
    
    var locationManager: CLLocationManager!
    let infoMarker = GMSMarker()
    
    override func loadView() {
        super.loadView()
        setupLocationManager()
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
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

        let facilitydata = JSON(marker.userData as Any)

        // 施設情報をUserDefaultsへ保存する
        let ud = UserDefaults.standard
        ud.set(marker.title!, forKey: "name")
        ud.set(facilitydata["facility_id"].string, forKey: "id")
print(facilitydata)

        var evalue = 0
        var comment_details: [String] = []
        if (facilitydata["comment"] != nil)
        {
            var evalues: [Int] = []
            facilitydata["comment"].forEach{(arg) in
                let (_, comment) = arg
                if(comment["comment_value"] != nil)
                {
                    evalues.append(Int(comment["comment_value"].string!)!)
                }
                if(comment["comment_detail"] != nil)
                {
                    comment_details.append(comment["comment_detail"].string!)
                }
            }
            evalue = evalues.reduce(0, +) / Int(evalues.count)
            
        }
        ud.set(comment_details, forKey: "comment_details")
        ud.set(evalue, forKey: "evalue")

        infoMarker.snippet = marker.snippet!
        infoMarker.title = marker.title!
        infoMarker.opacity = 0;
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
        return false
    }

    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 300, height: 300))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6

        let facility = JSON(marker.userData as Any)

        if (facility == "unknown") {
            return nil;
        }
        
        let lbl1 = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 15))
        //        lbl1.text = marker.title!
        lbl1.text = facility["facility_name"].string
        view.addSubview(lbl1)
        
        let lbl2 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
        //        lbl2.text = marker.snippet!
        lbl2.text = facility["facility_possible_time"].string
        lbl2.font = UIFont.systemFont(ofSize: 14, weight: .light)
        view.addSubview(lbl2)
        
        let lbl3 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + lbl2.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
        lbl3.text = facility["facility_possible_day"].string
        lbl3.font = UIFont.systemFont(ofSize: 14, weight: .light)
        lbl3.numberOfLines = 0
        lbl3.sizeToFit()
        view.addSubview(lbl3)
        
//        var rect: CGSize = lbl3.sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        let lbl4 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + lbl3.frame.size.height + 25, width: view.frame.size.width - 16, height: 15))
        lbl4.text = facility["facility_station"].string
        lbl4.font = UIFont.systemFont(ofSize: 14, weight: .light)
        lbl4.numberOfLines = 0
        lbl4.sizeToFit()
        view.addSubview(lbl4)
        
        let lbl5 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + lbl4.frame.size.height + 30, width: view.frame.size.width - 16, height: 15))
        lbl5.text = facility["facility_url"].string
        lbl5.font = UIFont.systemFont(ofSize: 14, weight: .light)
        lbl5.numberOfLines = 0
        lbl5.sizeToFit()
        view.addSubview(lbl5)
        
        //        let lbl4: UITextField = UITextField()
        //        lbl4.frame = CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + lbl2.frame.size.height + lbl3.frame.size.height + 5, width: view.frame.size.width - 16, height: 90)
        //        lbl4.text = facility["facility_possible_day"].string
        //        lbl4.font = UIFont.systemFont(ofSize: 14, weight: .light)
        //        lbl4.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        //        lbl4.layer.borderWidth = 1
        //        view.addSubview(lbl4)
        //
        //        let lbl5 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + lbl2.frame.size.height + lbl3.frame.size.height + lbl4.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
        //        lbl5.text = "この施設の評価を送信する"
        //        lbl5.font = UIFont.systemFont(ofSize: 14, weight: .light)
        //        view.addSubview(lbl5)
        
        return view
    }

    
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
                spots.userData = map_data!["userData"] as Any
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
                    var spot:[String:Any] = [:]
                    spot["title"] = data["facility_name"].string!
                    spot["snippet"] = data["facility_remark"].string!
                    spot["latitude"] = data["facility_lat"].string!
                    spot["longitude"] = data["facility_lng"].string!
                    spot["userData"] = data
                    spots_dictionary[data["facility_name"].string!] = spot
                }
                apiResponse(spots_dictionary)
        }
    }
}


