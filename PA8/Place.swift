//
//  Place.swift
//  PA8
//
//  Created by Rebekah Hale on 11/27/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
//

/*
ID
You’ll need this to use Google Places Place Details to get extra, more detailed information about the place for displaying in PlaceDetailViewController

Name, vicinity, and rating
You’ll need these to display a place in a cell in the table view in PlaceTableViewController

Photo reference
You’ll need this to use Google Places Place Photos to get a photo of the place for displaying in PlaceDetailViewController

*/
import GooglePlaces
import GoogleMaps
import Foundation

struct Place {
    var ID: String
    var name: String
    var vicinity: String
    var rating: String
    var photoRefrence: String
    var openingHours: String
    
}
