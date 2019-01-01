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
import CoreData

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
        locationmanager.desiredAccuracy = kCLLocationAccuracyBestForNavigation   //Accuracy
        locationmanager.startUpdatingLocation()                     //Update the location
        locationmanager.startUpdatingHeading()
        
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
    let accelerationThreshold:Double = 1.0  //set detect threshold
    var dataList:[Double] = [0.0]
    var count = 0
    func myAccelerometer(){
        if motionManager.isAccelerometerAvailable{
            motionManager.accelerometerUpdateInterval = 1.0 / 40.0  // 40 Hz
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
                deviceManager, error in
                
                let userAcceleration:CMAcceleration = (deviceManager?.userAcceleration)!
                if (fabs(userAcceleration.y) > self.accelerationThreshold){
                    print("Low pass filter succeeded")
                }
            })
            motionManager.startAccelerometerUpdates(to:OperationQueue.current!){(data, error) in
                print(data as Any)
                if let data = self.motionManager.accelerometerData {
                    self.view.reloadInputViews()
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    
                    self.dataList.append(data.acceleration.y)
                    self.count += 1
                    //print(self.dataList)
                    
                    // Use the accelerometer data
                    self.xAccel!.text = "x: \(Double(x).rounded(toPlaces:3))"
                    self.yAccel!.text = "y: \(Double(y).rounded(toPlaces:3))"
                    self.zAccel!.text = "z: \(Double(z).rounded(toPlaces:3))"
                }//end if
            }
        }
    }//end func
    
    let locationmanager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        //let currentLocation = locations[0]   //currentLocation store the most recent location
        //var locationList:[CLLocation] = []
        let currentLocation = locations.last!
        let oldLocation = locations.first!
        
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude,currentLocation.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: myLocation,span: span)
        map.setRegion(region, animated:true)
        print("Present location : ,/(currentLocation.coordinate.latitude),/(currentLocation.coordinate.longitude)")
        
        if (oldLocation as CLLocation? != nil){
            let oldCoordinates = oldLocation.coordinate
            let newCoordinates = currentLocation.coordinate
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            map.addOverlay(polyline)
            //map.addOverlay(polyline, level: MKOverlayLevel.aboveRoads)
        }
    }//end function
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let dataValue_y = fabs(self.motionManager.accelerometerData?.acceleration.y ?? 0)
        let prev_dataValue_y = fabs(self.dataList[count-1])
        
        let comp = fabs(dataValue_y - prev_dataValue_y)
        if (overlay is MKPolyline) {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if (comp > 0.16){
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 6.0
                print("red")
            }
            else if (comp > 0.12 && comp < 0.16){
                renderer.strokeColor = UIColor.orange
                renderer.lineWidth = 6.0
                 print("orange")
            }
            else if (comp > 0.08 && comp < 0.12){
                renderer.strokeColor = UIColor.green
                renderer.lineWidth = 6.0
                print("green")
            }
            else if (comp > 0.04 && comp < 0.08){
                renderer.strokeColor = UIColor.yellow
                renderer.lineWidth = 6.0
                 print("yellow")
            }
            else{
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 6.0
                print("publish overlay blue line")
            }
            
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:Error){
        print("Unable to access the location")
    }
    
    //function to add annotation to map view
    func addAnnotationsOnMap(locationToPoint : CLLocation){
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0] as CLPlacemark
                annotation.title = placemark.name
                self.map.addAnnotation(annotation)
                print("add annotation")
            }
        })
    }//end function
    
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
