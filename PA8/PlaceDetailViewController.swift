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

class PlaceDetailViewController: UIViewController {
    
    var placeOptional: Place? = nil

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var ifOpenLabel: UILabel!
    @IBOutlet var reviewText: UITextField!
    @IBOutlet var image: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let place = placeOptional {
            GooglePlacesAPI.fetchPlaceDetails(placeID: place.ID) { (placeDetailsOptional) in
                if let receivedDetailPlace = placeDetailsOptional {
                    self.nameLabel.text = place.name
                    self.adressLabel.text = receivedDetailPlace.formattedAddress
                    self.phoneNumberLabel.text = receivedDetailPlace.formattedPhoneNumber
                    self.ifOpenLabel.text = place.openingHours
                    self.reviewText.text = receivedDetailPlace.review
                }
            }
            GooglePlacesAPI.fetchPlacePhoto(fromURLString: place.photoRefrence) { (imageOptional) in
                if let imageView = self.image, let image = imageOptional {
                    imageView.image = image
                }
            }
        }
    }
}
