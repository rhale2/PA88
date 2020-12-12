//
//  ViewController.swift
//  PA8
//
//  This file handles the PlaceTableViewController
//  CPSC 315-02, Fall 2020
//  Programming Assignment #8
//  No sources to cite
//

//  Created by Rebekah Hale and Sophie Braun on 11/27/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MBProgressHUD
import CoreLocation

/**
 Controlls the main view controller for Places.
 */
class PlaceTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    var places: [Place] = [Place]()
    var placePhotos: [PlacePhoto] = [PlacePhoto]()
    var placeDetails: [PlaceDetails] = [PlaceDetails]()
    var placesClient: GMSPlacesClient!
    var currentSearch: String = ""
    var latitude: String = ""
    var longitude: String = "-"
    var search: Bool = false
    let locationManager = CLLocationManager()
    var currPlacesIndex: Int? = nil
    
    @IBOutlet var searchBarButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    /**
     Refreshes the tableview results.
     
     - Parameter sender: The update button.
     */
    @IBAction func updateLocationButton (_ sender: UIBarButtonItem) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        GooglePlacesAPI.fetchPlaces(input: currentSearch, latitude: latitude, longitude: longitude) { (placeOptional) in
            if let recievedPlaces = placeOptional {
                print("in ViewController got the array back")
                self.places = recievedPlaces
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.reloadData()
        }
        if (currentSearch == "") {
            places.removeAll()
            self.tableView.reloadData()
        }
    }
    
    /**
     Refreshes the tableview results.
     
     - Parameter sender: The search button.
     */
    @IBAction func searchButtonPressed (_ sender: UIBarButtonItem) {
        showSearchBar()
    }
    
    /**
     Complies the view.
     */
    override func viewDidLoad () {
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
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "DetailSegue" {
                if let placeDetailVC = segue.destination as? PlaceDetailViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let place = places[indexPath.row]
                        placeDetailVC.placeOptional = place
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
    func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
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
    
    /**
     Handles getting the coordinates of the user. 
     
     - Parameter manager: The CoreLocationManager.
     - Parameter locations: The locations.
     */
    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        let coordinate = location.coordinate
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /**
     Fails if no location.
     
     - Parameter manager: The CoreLocationManager.
     - Parameter error: The error.
     */
    func locationManager (_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location \(error)")
    }
    
    /**
     Enables Location Services.
     */
    func setupLocationServices () {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    /**
     Grabs the searchText and searches for a Place.
     
     - Parameter searchBar: The searchBar.
     - Parameter searchText: The text entered in the searchBar.
     */
    func searchBar (_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearch = searchText
        MBProgressHUD.showAdded(to: self.view, animated: true)
        GooglePlacesAPI.fetchPlaces(input: currentSearch, latitude: latitude, longitude: longitude) { (placeOptional) in
            if let recievedPlaces = placeOptional {
                print("in ViewController got the array back")
                self.places.append(contentsOf: recievedPlaces)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            if (searchText.isEmpty) {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                self.places.removeAll()
                self.tableView.reloadData()
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            self.tableView.reloadData()
        }
    }
    
    /**
     Presents the searchBar.
     */
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
