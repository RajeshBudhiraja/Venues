//
//  Utilities.swift
//  Venues
//
//  Created by Rajesh Budhiraja on 03/01/19.
//  Copyright © 2019 Rajesh Budhiraja. All rights reserved.
//

import UIKit

class Utilities
{
    
    static func alert(title:String,message:String) -> UIAlertController
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
    
// Optain clientID and secret key from https://developer.foursquare.com
    static let fourSquareClientID = "A"
    static let fourSquareSecret = "A"
    
    static func getDateString() -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMDD"
        return formatter.string(from: date)
    }
    
    static let categoriesDict : [(icon:String,categoryID:String,color:UIColor)] = [("food","4d4b7105d754a06374d81259",UIColor.green),("entertainment","4d4b7104d754a06370d81259",UIColor.blue),("outdoor","4d4b7105d754a06377d81259",UIColor.purple),("nightlife","4bf58dd8d48988d116941735",UIColor.red),("shopping","4d4b7105d754a06378d81259",UIColor.orange),("closeMenu","",UIColor.white)]
}
