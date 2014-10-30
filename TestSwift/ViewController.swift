//
//  ViewController.swift
//  TestSwift
//
//  Created by Bram Koot on 29-10-14.
//  Copyright (c) 2014 Bram Koot. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainLabel: UILabel!
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        loadChargePoints(mapView.region)
    }
    
    @IBAction func buttonClick(sender: UIButton) {
        mapView.removeAnnotations(mapView.annotations!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)), animated: false)
        
        let point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)
        point.title = "humor"
        mapView.addAnnotation(point);
        
        println("did load")
    }
    
    func loadChargePoints(region: MKCoordinateRegion) {
        
        
        let queryString = "centerLatitude=\(region.center.latitude)&centerLongitude=\(region.center.longitude)&deltaLatitude=\(region.span.latitudeDelta)&deltaLongitude=\(region.span.longitudeDelta)"
        
        var session = NSURLSession.sharedSession()
        var url = NSURL.init(string:"http://192.168.178.26/chargepoints.php?\(queryString)")!
        
        println("requesting stuff on url \(url)");
        
        var task = session.dataTaskWithURL(url, completionHandler: {
            data, response, error in
            println("humor dan")
            
            let json = JSON(data:data)
            var point:MKPointAnnotation
            
            if let chargepoints = json["data"].arrayValue {
                let points = NSMutableArray()
                for chargepoint in chargepoints {
                    if let lat = chargepoint["lat"].doubleValue {
                        if let lng = chargepoint["lng"].doubleValue {
                            println("has lng")
                            if let address = chargepoint["address"].stringValue {
                                println(self.mapView)
                                
                                point = MKPointAnnotation()
                                point.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                                point.title = address
                                
                                println("trying to place a point with lat = \(lat), lng = \(lng) and address = \(address)")
                                
                                points.addObject(point)
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    self.mapView.addAnnotations(points)
                })
                println("Done adding charge points")
            }
            
            if let responseTime = json["time"].integerValue {
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    self.mainLabel.text = "\(responseTime) ms"
                })
                
            }
        })
        task.resume()
        println("task: \(task)")
        
    }
    
    override func viewDidAppear(animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

