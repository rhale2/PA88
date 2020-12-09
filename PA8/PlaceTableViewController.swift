//
//  ViewController.swift
//  PA8
//
//  Created by Rebekah Hale on 11/27/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
//

/*
 The user interface has (at a minimum) a table view, a search bar, and an update location button
 When the update location button is pressed, the user’s location is fetched and used for future nearby places searches
 When the search bar’s text field is empty, the table view is empty as well
 When the search bar’s cancel button is tapped, the table view should be cleared out
 When the user types in the search bar and presses the “Search” button on the keyboard (recall: use cmd + K to bring up the keyboard so you can see the Search button), the app fetches nearby places the user that match user’s search text using a Google Places Nearby Search
 While fetching/parsing data, show an indeterminate progress indicator using the MBProgressHUD Cocoapod
 The app requests nearby places that
 Contain the users search text as a keyword
 Are ranked by distance to their current location
 The app displays the returned places in a table view, one cell for each place
 The cell displays (at a minimum) the place’s
 Name
 Vicinity
 Rating
 Tapping on a cell should bring you to PlaceDetailViewController’s screen
 */

import UIKit
import GoogleMaps
import GooglePlaces
import MBProgressHUD
import CoreLocation

class PlaceTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    var places: [Place] = [Place]()
    var placesClient: GMSPlacesClient!
    var search: Bool = false
    let locationManager = CLLocationManager()
    var currPlacesIndex: Int? = nil
    
    @IBOutlet var searchBarButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func updateLocationButton(_ sender: UIBarButtonItem) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        GooglePlacesAPI.fetchPlaces { (placeOptional) in
            if let places = placeOptional {
                self.places = places
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        showSearchBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBarButton = navigationItem.rightBarButtonItem
        placesClient = GMSPlacesClient.shared()
        
        if CLLocationManager.locationServicesEnabled() {
            print("enabled")
            setupLocationServices()
        }
        else {
            print("disabled")
            // the user has turned off location services, airplane mode, HW failure, etc.
        }
              
        // Do any additional setup after loading the view.
    }
    
    /**
    handles the preparation for segue
     
     - Parameter segue: The UIStorySegue
     - Parameter sender: The source
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "DetailSegue" {
                if let placeDetailVC = segue.destination as? PlaceDetailViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let place = places[indexPath.row]
                        //set placeDetailVC
                    }
                }
            }
        }
    }
    
    /**
     Sets how many rows there should be for the Table View.
     
     - Parameter tableView: The Table View.
     - Parameter section: The number of sections in the Table View.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return places.count
        }
        return 0
    }
    
    /**
    Places a place in a cell.
         
    - Parameter tableView: The Table View.
    - Parameter indexPath: The cell position.
    */
    func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let place = places[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        if let text = cell.textLabel, let label = cell.detailTextLabel {
            text.text = "\(place.name) (\(place.rating)⭐️)"
            label.text = "\(place.vicinity)"
        }
        
        return cell
    }
    
    /**
     Handles the moving of cells.
     
     - Parameter tableView: The Table View to edit.
     - Parameter sourceIndexPath: The original loctation of the cell.
     - Parameter destinationIndexPth: The new location of the cell.
     */
    func tableView (_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let place = places.remove(at: sourceIndexPath.row)
        places.insert(place, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    /**
     Handels the deletion of a cell.
     
     - Parameter tableView: The Table View.
     - Parameter editingStyle: The cell editing style.
     - Parameter indexPath: The cell position.
     */
    func tableView (_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        let coordinate = location.coordinate
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)
            
        GooglePlacesAPI.latitude = latitude
        GooglePlacesAPI.longitude = longitude
    }
        
    func locationManager (_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location \(error)")
    }
        
    func setupLocationServices () {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
        
    func searchBar (_ searchBar: UISearchBar, textDidChange searchText: String) {
        GooglePlacesAPI.input = searchText
        GooglePlacesAPI.googleNearBySearchesURL(input: GooglePlacesAPI.input, latitude: GooglePlacesAPI.latitude, longitude: GooglePlacesAPI.longitude)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        GooglePlacesAPI.fetchPlaces { (placeOptional) in
            if let places = placeOptional {
                self.places = places
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        tableView.reloadData()
    }
        
    func showSearchBar () {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.alpha = 1
        }, completion: { finished in
            self.searchBar.becomeFirstResponder()
        })
    }
}
