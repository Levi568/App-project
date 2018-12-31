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
    
    func myAccelerometer(){
        if motionManager.isAccelerometerAvailable{
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
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
                    
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let entity = NSEntityDescription.entity(forEntityName: "Entity", in: context)
                    let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                    newEntity.setValue(data.acceleration.y, forKey: "data")
                    do{
                    try context.save()
                    }catch{
                        print("Fail saving")
                    }
                    
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
        /*var previousLocation : CLLocation!
        if (previousLocation as CLLocation? != nil){
            //case if previous location exists
            if previousLocation.distance(from: currentLocation) > 1000 {
                addAnnotationsOnMap(locationToPoint: currentLocation)
                previousLocation = currentLocation
            }
        }
        else{
            //in case previous location doesn't exist
            addAnnotationsOnMap(locationToPoint: currentLocation)
            previousLocation = currentLocation
        }*/
        /*if oldLocation as CLLocation? != nil{
            addAnnotationsOnMap(locationToPoint: oldLocation)
        }
        else{
            print("Unable to access the location")
        }*/
    }//end function

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let dataValue_y = fabs(self.motionManager.accelerometerData?.acceleration.y ?? 0)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Entity")
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request)
            for data in result as![NSManagedObject]{
                data = data.value(forKey: "data")as! Float
            }
        }catch{
            print("Request failing")
        }
        
        if (overlay is MKPolyline) {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if (dataValue_y > 1.2){
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 6.0
            }
            else if (dataValue_y > 1.1 && dataValue_y < 1.2){
                renderer.strokeColor = UIColor.orange
                renderer.lineWidth = 6.0
            }
            else if (dataValue_y > 1.0 && dataValue_y < 1.1){
                renderer.strokeColor = UIColor.yellow
                renderer.lineWidth = 6.0
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
