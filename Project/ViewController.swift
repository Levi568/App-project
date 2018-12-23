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
        
        //Authorization for user location
        let status = CLLocationManager.authorizationStatus()
        if (status == .restricted || status == .denied || status == .notDetermined){
            locationmanager.requestWhenInUseAuthorization()
        }
        locationmanager.delegate = self
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest   //Accuracy
        locationmanager.startUpdatingLocation()                     //Update the location
        
        //mapview setup to show user location
        map.delegate = self
        map.showsUserLocation = true
        map.mapType = MKMapType(rawValue: 0)!
        map.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        myAccelerometer()
    }
    //Accelerometer
    var motionManager = CMMotionManager()
    var timer: Timer!
    let accelerationThreshold:Double = 0.8  //set detect threshold
    
    func myAccelerometer(){
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
            deviceManager, error in
            
            let userAcceleration:CMAcceleration = (deviceManager?.userAcceleration)!
            if (fabs(userAcceleration.y) > self.accelerationThreshold){
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
    
    let locationmanager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        //let currentLocation = locations[0]   //currentLocation store the most recent location
        let currentLocation = locations.last!
        let oldLocation = locations.first!
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude,currentLocation.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: myLocation,span: span)
        
        map.setRegion(region, animated:true)
        self.map.showsUserLocation = true
        print("Present location : ",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude)
        //drawing path or route covered
        if let oldLocationNew = oldLocation as CLLocation?{
            let oldCoordinates = oldLocationNew.coordinate
            let newCoordinates = currentLocation.coordinate
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            map.addOverlay(polyline)
            print("addOverlay")
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            if (fabs(self.motionManager.accelerometerData?.acceleration.y ?? 0) > accelerationThreshold){
                pr.strokeColor = UIColor.blue
                pr.lineWidth = 7
                print("publish overlay blue line")
            }
            else{
                pr.strokeColor = UIColor.red
                pr.lineWidth = 7
                print("publish overlay red line")
            }
            return pr
        }
        return MKOverlayRenderer()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:Error){
        print("Unable to access the location")
    }
    
    //function to add annotation to map view
    /*func addAnnotationsOnMap(locationToPoint : CLLocation){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        let geoCoder = CLGeocoder ()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                var addressDictionary = placemark.addressDictionary;
                annotation.title = addressDictionary?["Name"] as? String
                self.map.addAnnotation(annotation)
            }
        })
        
    }*/
    /*var previousLocation : CLLocation!
    if let previousLocationNew = previousLocation as CLLocation?{
        //case if previous location exists
        if previousLocation.distanceFromLocation(newLocation) > 200 {
            addAnnotationsOnMap(newLocation)
            previousLocation = newLocation
        }
    }
    else{
        //in case previous location doesn't exist
        addAnnotationsOnMap(newLocation)
        previousLocation = newLocation
    }*/
    
    //Set mapType to standard and satellite
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        map.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
}
extension Double{
    func rounded(toPlaces places:Int)->Double{
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
