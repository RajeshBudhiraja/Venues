//
//  DataManager.swift
//  Venues
//
//  Created by Rajesh Budhiraja on 04/01/19.
//  Copyright © 2019 Rajesh Budhiraja. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import SwiftyJSON

class DataManager:UpdateParameters {
 
    
 
    
    
    //MARK: Variables.
    let urlString = "https://api.foursquare.com/v2/venues/search"
    let categoriesUrl = "https://api.foursquare.com/v2/venues/categories"
    var delegate:DataManagerDelegate?
    var data : [VenueResponse] = [VenueResponse]()
    var filter: Bool = false
    var categoryID: String = ""
    
    //MARK: Networking
    func getVenues(dateString:String,latLong:String,query:String,completion:@escaping (Bool) -> Void)
    {
        let param:[String:String]
        if filter {

            param = ["client_id":Utilities.fourSquareClientID,"client_secret":Utilities.fourSquareSecret,"v":dateString,"ll":latLong,"query":query,"limit":"20","radius":"1000","categoryId":self.categoryID]
        }
        else {

        param = ["client_id":Utilities.fourSquareClientID,"client_secret":Utilities.fourSquareSecret,"v":dateString,"ll":latLong,"query":query,"limit":"20","radius":"1000"]
        }
        self.data = [VenueResponse]()
     
        
        Alamofire.request(urlString,method:.get,parameters:param).responseJSON
            {
                response in
                if response.result.isSuccess {
                    let venueResponse:JSON = JSON(response.result.value!)
                    let res = venueResponse["response"]
                    let code = venueResponse["meta"]["code"]
                    if code != 200 {
                        self.delegate?.apiUnavailable()
                        return
                    }
                    let venues = res["venues"]
                
                    for i in 0 ..< venues.count {
                        let location = venues[i]["location"]
                        let formattedAddressArray = location["formattedAddress"]
                        
                        let formattedAddress = formattedAddressArray[0].stringValue+"\n"+formattedAddressArray[1].stringValue+"\n"+formattedAddressArray[3].stringValue
                        
                        let distance = location["distance"]
                        let name = venues[i]["name"]
                        
                        let lat = location["lat"]
                        let long = location["lng"]
                        
                        
                        
                        let venueModel = VenueResponse()
                        venueModel.address = formattedAddress
                        venueModel.distance = distance.stringValue
                        venueModel.name = name.stringValue
                        venueModel.lat = lat.stringValue
                        venueModel.long = long.stringValue
                        self.data.append(venueModel)
                       
                    }
                    
                    //TODO: Sorting venues according to distance.
                    self.delegate?.venueData = self.data.sorted{ Int($0.distance)! < Int($1.distance)!}

                   
                    completion(true)
                }
                else
                {
                    self.delegate?.internetIssue()
                }
                
        }
        
       
    }
    
    
    
}


protocol DataManagerDelegate {
    var venueData:[VenueResponse] {get set}
    func apiUnavailable()
    func internetIssue()
}


