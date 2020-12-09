//
//  PlaceDetailViewController.swift
//  PA8
//
//  Created by Rebekah Hale on 11/27/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
//

/*
 The user interface has (at a minimum) an image view for the place’s photo and labels for the following pieces of information about the selected place
 Name
 Address
 Phone number
 Whether the place is open now or not
 At least one review’s text
 
 More information if you want!
 Make a Place Detail request to get the above information
 While fetching/parsing data, show an indeterminate progress indicator using the MBProgressHUD Cocoapod
 */

import UIKit

class PlaceDetailViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var ifOpenLabel: UILabel!
    @IBOutlet var reviewText: UITextView!
    
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
