//
//  EarnStickersViewController.swift
//  One Star
//
//  Created by sid patel on 8/2/16.
//  Copyright © 2016 coretwist. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData
import AVFoundation
import MapKit

class EarnStickersViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, AVCaptureMetadataOutputObjectsDelegate{
    
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var stickerLocationMapView: MKMapView!
    var user: String = "user"
    
    @IBOutlet weak var userNm: UILabel!
    @IBOutlet weak var openCameraForScanButton: UIButton!
    let locationManager = CLLocationManager()
   
    var iphoneDevice = DeviceInfromation()
    
    
    
    
    
    @IBAction func openCameraForScan(_ sender: AnyObject) {
        
     
    }
    
   

    
    
    
    
    override func viewDidLoad()
    {
       super.viewDidLoad()
        
        userNm.text = user
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        print("battery level................................\(iphoneDevice.checkBatteryLevel())")
        
        iphoneDevice.checkBatteryState()
        
        print("In View didLoad...........................")
        
        
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        getLocationAddress(location: locations[0])
        
        
    }
    func getLocationAddress(location:CLLocation) {
        let geocoder = CLGeocoder()
        
       // print("-> Finding user address...")
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            var placemark:CLPlacemark!
            
            if error == nil && placemarks?.count > 0 {
                placemark = (placemarks?[0])! as CLPlacemark
                
                var addressString : String = ""
                if placemark.isoCountryCode == "TW" /*Address Format in Chinese*/ {
                    if placemark.country != nil {
                        addressString = placemark.country!
                    }
                    if placemark.subAdministrativeArea != nil {
                        addressString = addressString + placemark.subAdministrativeArea! + ", "
                    }
                    if placemark.postalCode != nil {
                        addressString = addressString + placemark.postalCode! + " "
                    }
                    if placemark.locality != nil {
                        addressString = addressString + placemark.locality!
                    }
                    if placemark.thoroughfare != nil {
                        addressString = addressString + placemark.thoroughfare!
                    }
                    if placemark.subThoroughfare != nil {
                        addressString = addressString + placemark.subThoroughfare!
                    }
                } else {
                    if placemark.subThoroughfare != nil {
                        addressString = placemark.subThoroughfare! + " "
                    }
                    if placemark.thoroughfare != nil {
                        addressString = addressString + placemark.thoroughfare! + ", "
                    }
                    if placemark.postalCode != nil {
                        //addressString = addressString + placemark.postalCode! + " "
                    }
                    if placemark.locality != nil {
                        addressString = addressString + placemark.locality! + ", "
                    }
                    if placemark.administrativeArea != nil {
                        addressString = addressString + placemark.administrativeArea! + " "
                    }
                    if placemark.country != nil {
                        addressString = addressString + placemark.country!
                    }
                }
                self.stickerLocationMapView.centerCoordinate = location.coordinate
                let reg = MKCoordinateRegionMakeWithDistance(location.coordinate, 1500, 1500)
                self.stickerLocationMapView.setRegion(reg, animated: true)
                self.stickerLocationMapView.showsUserLocation = true
                
                self.userLocation.text = addressString
                // self.addRadiusCircle(location: location)
            }
        })
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("location updated")
        
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        
        print("This is problem")
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    
    
    
    
    
    
    
}
