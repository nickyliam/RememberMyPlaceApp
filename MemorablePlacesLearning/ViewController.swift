//
//  ViewController.swift
//  MemorablePlacesLearning
//
//  Created by admin on 6/8/17.
//  Copyright © 2017 KahoTestSwitft. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate {
    @IBOutlet var map: MKMapView!
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let uilpr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(gestureRecognizer:)))
        uilpr.minimumPressDuration = 2
        map.addGestureRecognizer(uilpr)
        
        if activePlace == -1 {
            // to use GPS
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        } else {
            if places.count > activePlace {
                if let name = places[activePlace]["name"] {
                    if let lat = places[activePlace]["lat"] {
                        print(places[activePlace]["lat"]!)
                        if let lon = places[activePlace]["lon"]{
                            if let latitude = Double(lat){
                                if let longtitude = Double(lon){
                                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
                                    let region = MKCoordinateRegion(center: coordinate, span: span)
                                    
                                    map.setRegion(region, animated: true)
                                    
                                    
                                    let annotation = MKPointAnnotation()
                                    annotation.title = name
                                    annotation.coordinate = coordinate
                                    map.addAnnotation(annotation)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func longPress(gestureRecognizer:UIGestureRecognizer){
        
        if gestureRecognizer.state == UIGestureRecognizerState.began{ // only allow code below run once after pressed
            let touchPoint = gestureRecognizer.location(in: self.map)
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
           var title = ""
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            
                if error != nil{
                    print(error)
                } else {
                    if let placemark = placemarks?[0]{
                        if placemark.subThoroughfare != nil {
                            title += placemark.subThoroughfare! + " "
                        }
                        if placemark.thoroughfare != nil {
                            title += placemark.thoroughfare!
                        }
                    }
                    
                }
                
                if title == "" {
                    title = "Added \(NSDate())"
                }
                
                let newAnnotation = MKPointAnnotation()
                newAnnotation.title = title
                newAnnotation.coordinate = newCoordinate
                
                self.map.addAnnotation(newAnnotation)
                places.append(["name":title,"lat":String(newCoordinate.latitude),"lon":String(newCoordinate.longitude)])
                UserDefaults.standard.set(places, forKey: "places")

                
                
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        

        
        self.map.setRegion(region, animated: true)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

