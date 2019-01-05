//
//  MapViewController.swift
//  Venues
//
//  Created by Rajesh Budhiraja on 04/01/19.
//  Copyright © 2019 Rajesh Budhiraja. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,MapDelegate,MKMapViewDelegate {
   
    
  
    
    
    //MARK: Variables
    var initialLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    let regionRadius : CLLocationDistance = 2000
    var destinationLocation:CLLocation = CLLocation(latitude: 0, longitude: 0)
    var name = ""
    var currentLocationsPlacemark : CLPlacemark?
    var destinationsPlacemark : CLPlacemark?
    var currentMapItem:MKMapItem?
    var destinationMapItem:MKMapItem?
    
    //MARK: Annotations
    let currentAnnotation = MKPointAnnotation()
    let destinationAnnotation = MKPointAnnotation()
    
    //MARK: IBOutlets
    @IBOutlet weak var map: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Setting Delegate
        self.map.delegate = self
        
        //TODO: Setting initial point in map.
        centerMap(location: initialLocation)
        
        //TODO: Setting destination in map.
        self.addDestination(location: destinationLocation, name: name)
        
        //TODO: Converting coordinates to human readable address.
        CLGeocoder().reverseGeocodeLocation(destinationLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                self.destinationsPlacemark = placemarks[0]
                self.destinationMapItem = MKMapItem(placemark: MKPlacemark(placemark: self.destinationsPlacemark!))
               
            }
        }
        
  
        
    }
    
    
    //MARK: Messages
    func centerMap(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: self.regionRadius, longitudinalMeters: self.regionRadius)
        self.map.setRegion(coordinateRegion, animated: true)
        self.currentAnnotation.coordinate = location.coordinate
        currentAnnotation.title = "You are here."
        self.map.addAnnotation(currentAnnotation)
        
        //TODO: Converting coordinates to human readable address.
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            
            if let placemarks = placemarks {
                self.currentLocationsPlacemark = placemarks[0]
                self.currentMapItem = MKMapItem(placemark: MKPlacemark(placemark: self.currentLocationsPlacemark!))
                self.calculateRoute()
            }
            
        }

        
        
    }
    
    func addDestination(location: CLLocation,name:String) {
        self.destinationAnnotation.title = name
        self.destinationAnnotation.coordinate = location.coordinate
        self.map.addAnnotation(self.destinationAnnotation)
        
       
    }

    private func calculateRoute()
    {
        let request = MKDirections.Request()
        request.source = self.currentMapItem
        request.destination = self.destinationMapItem
        request.requestsAlternateRoutes = true
        request.transportType = .any

       let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            if let routeResponse = response?.routes {
                let quickestRoute:MKRoute = routeResponse.sorted{$0.expectedTravelTime < $1.expectedTravelTime}[0]
                self.map.addOverlay(quickestRoute.polyline)
                self.map.setVisibleMapRect(quickestRoute.polyline.boundingMapRect, animated: true)

                
               
            }
            else {
                print(error)
                self.present(Utilities.alert(title: "No Routes available.", message: ""),animated: true)
            }
            
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
}

