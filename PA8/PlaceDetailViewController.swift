//
//  PlaceDetailViewController.swift
//  PA8
//
//  This file handles the PLaceDetailViewController
//  CPSC 315-02, Fall 2020
//  Programming Assignment #8
//  No sources to cite
//

//  Created by Rebekah Hale and Sophie Braun on 11/27/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
//

import UIKit

/**
 Handles the detail screen for the table view.
 */
class PlaceDetailViewController: UIViewController {
    
    var placeOptional: Place? = nil

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var adressText: UITextView!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var ifOpenLabel: UILabel!
    @IBOutlet var reviewText: UITextView!
    @IBOutlet var image: UIImageView!
    
    /**
     Complies the view.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewText.isScrollEnabled = false
        
        if let place = placeOptional {
            GooglePlacesAPI.fetchPlaceDetails(placeID: place.ID) { (placeDetailsOptional) in
                if let receivedDetailPlace = placeDetailsOptional {
                    self.nameLabel.text = place.name
                    self.adressText.text = receivedDetailPlace.formattedAddress
                    self.phoneNumberLabel.text = receivedDetailPlace.formattedPhoneNumber
                    if (place.openingHours.description == "false") {
                        self.ifOpenLabel.text = "Open Now"
                    }
                    else {
                        self.ifOpenLabel.text = "Closed"
                    }
                    self.reviewText.text = receivedDetailPlace.review
                }
            }
            if place.photoRefrence != "" {
            GooglePlacesAPI.fetchPlacePhoto(fromURLString: place.photoRefrence) { (imageOptional) in
                if let imageView = self.image, let image = imageOptional {
                    imageView.image = image
                }
            }
            }
        }
    }
}
