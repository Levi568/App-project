//
//  ViewController.swift
//  Project
//
//  Created by Wei Li on 12/6/18.
//  Copyright © 2018 Levi. All rights reserved.
//
import UIKit
import GoogleMaps
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let locationManager = CLLocationManager()
        mapView.showsUserLocation = true
        
        
        if CLLocationManager.locationServicesEnabled() {
            if (CLLocationManager.authorizationStatus() == .restricted ||
                CLLocationManager.authorizationStatus() == .denied ||
                CLLocationManager.authorizationStatus() == .notDetermined){
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        else{
            print("Please turn on location service")
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
            self.mapView.setRegion(region, animated: true)
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error:Error){
            print("Unable to access the location")
        }
        
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        /*let lat = 42.640999
         let lon = -71.316711
         let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 13.0)
         let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
         view = mapView
         
         // Creates a marker in the center of the map.
         let marker = GMSMarker()
         marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
         marker.title = "Umass Lowell"
         marker.snippet = "Massachusetts"
         marker.map = mapView*/
        
    }
}

