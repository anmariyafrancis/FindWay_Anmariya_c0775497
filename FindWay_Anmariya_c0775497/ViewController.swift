//
//  ViewController.swift
//  FindWay_Anmariya_c0775497
//
//  Created by user176498 on 6/14/20.
//  Copyright © 2020 user176498. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var btnFindWay: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentType: UISegmentedControl!
    
    let latitude: CLLocationDegrees = 43.64
    let longitude: CLLocationDegrees = -79.38
    
    var locationManager = CLLocationManager()
    var aLat: CLLocationDegrees??
    var aLon: CLLocationDegrees??
    var location: CLLocation?
    
     @IBAction func indexChanged(_ sender: Any) {
           
            yourWay()
    }
     @IBAction func findMyWay(_ sender: Any) {
            yourWay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
       
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        //mapView.isZoomEnabled = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tap)
    }
    
    
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
        {
            
           // location = locations.first!
            //
            
            let userLocation = locations[0]
            
            let latitude = userLocation.coordinate.latitude
            let longitude = userLocation.coordinate.longitude
    
            displayLocation(latitude: latitude, longitude: longitude, title: "Your Location", subtitle: "you are here")
            //locationManager.stopUpdatingLocation()
        }
    
        func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String) {
               // 2 - define delta latitude and delta longitude for the span
               let latDelta: CLLocationDegrees = 0.05
               let lngDelta: CLLocationDegrees = 0.05
               
               // 3 - creating the span and location coordinate and finally the region
               let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
               let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
               let region = MKCoordinateRegion(center: location, span: span)
               
               // 4 - set region for the map
            
               mapView.setRegion(coordinateRegion, animated: true)
               
        
           }
    
    
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3;
        return renderer
    }
    
    
      @objc func doubleTapped(sender: UIGestureRecognizer){
           
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    
      func yourWay(){
            self.mapView.removeOverlays(self.mapView.overlays)
           
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!), addressDictionary: nil))
        
        if(aLat == nil || aLon == nil)
        {
                let alertController = UIAlertController(title: "Error", message:
                "Please select your destination!!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))

                self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: aLat as! CLLocationDegrees, longitude: aLon as! CLLocationDegrees), addressDictionary: nil))
            request.requestsAlternateRoutes = false
        }
       
        switch segmentType.selectedSegmentIndex
        {
            case 0:
                request.transportType = .walking
            case 1:
                request.transportType = .automobile
            default:
                break
        }
        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    func addAnnotation(location: CLLocationCoordinate2D){
           let oldAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(oldAnnotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            aLat = annotation.coordinate.latitude
            aLon = annotation.coordinate.longitude
            annotation.title = "Destination"
            annotation.subtitle = "Here is your place"
            self.mapView.addAnnotation(annotation)
        }
}


