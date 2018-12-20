//
//  ViewController.swift
//  Project
//
//  Created by Wei Li on 12/6/18.
//  Copyright © 2018 Levi. All rights reserved.
//
import UIKit
import MapKit
import CoreMotion
import CoreLocation
import simd

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    //@IBOutlet weak var graph: GraphView!
    @IBOutlet weak var xAccel:UITextField!
    @IBOutlet weak var yAccel:UITextField!
    @IBOutlet weak var zAccel:UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //mapView.showsUserLocation = true
        //mapView.delegate = self
        locationmanager.delegate = self
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest   //Accuracy
        locationmanager.requestWhenInUseAuthorization()             //Authorization for user location
        locationmanager.startUpdatingLocation()                     //Update the location
        
    }
    
    let locationmanager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(locations[0].coordinate.latitude,locations[0].coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: myLocation,span: span)
        
        map.setRegion(region, animated:true)
        self.map.showsUserLocation = true
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error:Error){
        print("Unable to access the location")
    }
    
    //Accelerometer
    let motionManager = CMMotionManager()
    var timer: Timer!

    func myAccelerometer(){
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
        motionManager.startAccelerometerUpdates() //start it without a handler
        
        if let data = motionManager.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            // Use the accelerometer data
            self.xAccel.text = "x: \x"
            self.yAccel.text = "y: \y"
            self.zAccel.text = "z: \z"
        }//end if
        
        
    }//end func
    
    
    
    
}

