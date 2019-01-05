//
//  ViewController.swift
//  Venues
//
//  Created by Rajesh Budhiraja on 03/01/19.
//  Copyright © 2019 Rajesh Budhiraja. All rights reserved.
//

import UIKit
import CoreLocation
import CircleMenu

class ViewController: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,DataManagerDelegate,CircleMenuDelegate{
    
    //MARK: Variables
    var selectedIndex = 0
    var categoryDelegate:UpdateParameters?
    let locationManager = CLLocationManager()
    let dataManager = DataManager()
    var lattitude:String = ""
    var longitude:String = ""
    var mapDelegate:MapDelegate?
    var currentLocation:CLLocation?
    
    //MARK: DataManager Protocol
    var venueData: [VenueResponse] = [VenueResponse]()
    func apiUnavailable() {
        present(Utilities.alert(title: "Server is unavailable.", message: "Please try again later."), animated: true)
    }
    
    func internetIssue() {
        present(Utilities.alert(title: "Connection issue.", message: "Please check your connection."), animated: true)
    }

  
    //MARK: IBOutlets.
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var venueList: UITableView!
    @IBOutlet weak var categoriesButton: CircleMenu!
    
    
    //MARK: Constraints
    @IBOutlet weak var textfieldButtonConstraints: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Settings for textfield
        self.searchField.layer.borderColor = UIColor.white.cgColor
        self.searchField.borderStyle = .roundedRect
        self.textfieldButtonConstraints.constant = UIScreen.main.bounds.width/2
        self.searchField.sizeToFit()
        self.searchField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        self.hideKeyboard()
        
        //TODO: Setting delegates and datasource
        self.locationManager.delegate = self
        self.searchField.delegate = self
        self.venueList.delegate = self
        self.venueList.dataSource = self
        self.dataManager.delegate = self
        self.categoriesButton.delegate = self
        self.categoryDelegate = self.dataManager
        //TODO: Settings for location manager.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestWhenInUseAuthorization()
        
        //TODO: Settings for table.
        self.venueList.register(UINib(nibName: "VenueCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.venueList.rowHeight = UITableView.automaticDimension

        
        //TODO: Setting title for navigation bar.
        self.navigationController?.navigationBar.topItem?.title = "Welcome"
        
        //TODO: Making button cicrular
        self.categoriesButton.layer.cornerRadius = 0.5 * self.categoriesButton.bounds.size.width
                
    }
    
  
    //MARK: Location manager's delegate methods.
    
    //TODO: Fetching current location.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            self.lattitude = "\(location.coordinate.latitude)"
            self.longitude = "\(location.coordinate.longitude)"
            self.currentLocation = location
            
            //TODO: Doing initial search as soon as location is identified.
            perform(#selector(textDidChange))
        }
    }
    
    //TODO: Failed to update.
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        present(Utilities.alert(title: "Failed to updare location", message: "Please allow us to use GPS. If access is already provided, kindly try again."),animated: true)
    }
    
    
    //MARK: Textfield's methods.
    
    @objc func textDidChange()
    {
        self.dataManager.getVenues(dateString: Utilities.getDateString(), latLong: self.lattitude+","+self.longitude, query: self.searchField.text!) {
            result in
            if result {
                self.venueList.reloadData()
            }
        }
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    //MARK: Table's delegate methods.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.venueData.count == 0 {
            self.venueList.isHidden = true
        }
        else {
            self.venueList.isHidden = false
        }
        return self.venueData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.venueList.dequeueReusableCell(withIdentifier: "cell") as! VenueCell
        cell.name.text = self.venueData[indexPath.row].name
        cell.address.text = self.venueData[indexPath.row].address
        cell.distance.text = self.venueData[indexPath.row].distance + "m"
        
        
        cell.selectionStyle = .none
        return cell
    }

    //MARK: Segue related operation.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        performSegue(withIdentifier: "maps", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination as! MapDelegate
        destination.initialLocation = self.currentLocation!
        let lat = Double(self.venueData[self.selectedIndex].lat)!
        let long = Double(self.venueData[self.selectedIndex].long)!
        destination.name = self.venueData[self.selectedIndex].name
        destination.destinationLocation = CLLocation(latitude: lat, longitude: long)
    }
    
    //MARK: Categories Button related operations.
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = Utilities.categoriesDict[atIndex].color.withAlphaComponent(0.7)
        button.setImage(UIImage(named: Utilities.categoriesDict[atIndex].icon), for: .normal)
        button.tintColor = UIColor.black
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        
        switch Utilities.categoriesDict[atIndex].icon {
        case "closeMenu":
            self.categoriesButton.setBackgroundImage(UIImage(named: "menu"), for: .normal)
            self.categoryDelegate?.filter = false
            self.categoryDelegate?.categoryID = Utilities.categoriesDict[atIndex].categoryID
            perform(#selector(textDidChange))
        case "food":
            self.categoriesButton.setBackgroundImage(UIImage(named: "food"), for: .normal)
            self.categoryDelegate?.filter = true
            self.categoryDelegate?.categoryID = Utilities.categoriesDict[atIndex].categoryID
            perform(#selector(textDidChange))
        case "entertainment":
            self.categoriesButton.setBackgroundImage(UIImage(named: "entertainment"), for: .normal)
            self.categoryDelegate?.filter = true
            self.categoryDelegate?.categoryID = Utilities.categoriesDict[atIndex].categoryID
            perform(#selector(textDidChange))
        case "nightlife":
            self.categoriesButton.setBackgroundImage(UIImage(named: "nightlife"), for: .normal)
            self.categoryDelegate?.filter = true
            self.categoryDelegate?.categoryID = Utilities.categoriesDict[atIndex].categoryID
            perform(#selector(textDidChange))
        case "outdoor":
            self.categoriesButton.setBackgroundImage(UIImage(named: "outdoor"), for: .normal)
            self.categoryDelegate?.filter = true
            self.categoryDelegate?.categoryID = Utilities.categoriesDict[atIndex].categoryID
            perform(#selector(textDidChange))
        case "shopping":
            self.categoriesButton.setBackgroundImage(UIImage(named: "shopping"), for: .normal)
            self.categoryDelegate?.filter = true
            self.categoryDelegate?.categoryID = Utilities.categoriesDict[atIndex].categoryID
            perform(#selector(textDidChange))
        default:
            print("No Option Possible")
        }
    }
}




protocol UpdateParameters {
    var filter:Bool {get set}
    var categoryID:String {get set}
}

//TODO: Hide keyboard when touched away from it.
extension ViewController {
    func hideKeyboard()
    {
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
