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
        
        //Authorization for user location
        if (CLLocationManager.authorizationStatus() == .restricted ||
            CLLocationManager.authorizationStatus() == .denied ||
            CLLocationManager.authorizationStatus() == .notDetermined){
            locationmanager.requestWhenInUseAuthorization()
        }
        locationmanager.delegate = self
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest   //Accuracy
        locationmanager.startUpdatingLocation()                     //Update the location
        
        myAccelerometer()
        
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
    var motionManager = CMMotionManager()
    var timer: Timer!

    func myAccelerometer(){
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
            deviceManager, error in
            let accelerationThreshold:Double = 0.8
            let userAcceleration:CMAcceleration = (deviceManager?.userAcceleration)!
            if (fabs(userAcceleration.y) > accelerationThreshold){
                print("Low pass filter succeeded")
            }
        })
        motionManager.startAccelerometerUpdates(to:OperationQueue.current!){(data, error) in   //start it without a handler
        print(data as Any)
            if let data = self.motionManager.accelerometerData {
                self.view.reloadInputViews()
                let x = data.acceleration.x
                let y = data.acceleration.y
                let z = data.acceleration.z
                // Use the accelerometer data
                self.xAccel!.text = "x: \(Double(x).rounded(toPlaces:3))"
                self.yAccel!.text = "y: \(Double(y).rounded(toPlaces:3))"
                self.zAccel!.text = "z: \(Double(z).rounded(toPlaces:3))"
            }//end if
        }
    }//end func
}
extension Double{
    func rounded(toPlaces places:Int)->Double{
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
