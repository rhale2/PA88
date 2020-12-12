//
//  GooglePlacesAPI.swift
//  PA8
//
//  This file handles the Google Places API & parsing JSON
//  CPSC 315-02, Fall 2020
//  Programming Assignment #8
//  No sources to cite
//

//  Created by Rebekah Hale and Sophie Braun on 11/27/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
//
//

import Foundation
import UIKit

struct GooglePlacesAPI {
    private static let apiKey = "AIzaSyCqr-r3261KQcBV7G_BT-HZyy7SBKdAoxs"
    
    static func googleNearBySearchesURL (input: String, latitude: String, longitude: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        
        let params = [
            "key": GooglePlacesAPI.apiKey,
            "location": "\(latitude), \(longitude)",
            "radius": "1000",
            "keyword": "\(input)"
        ]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = queryItems
        let url = components.url!
        print(url)
        return url
        
    }
    
    
    static func googlePlaceDetailsURL (placeID: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/details/json?"
        
        let params = [
            "key": GooglePlacesAPI.apiKey,
            "place_id": "\(placeID)",
        ]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = queryItems
        let url = components.url!
        print("DETAIL: \(url)")
        return url
    }
    
    
    static func googlePlacePhotosURL (photoRefrence: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/photo?"
        
        let params = [
            "key": GooglePlacesAPI.apiKey,
            "photoreference": "\(photoRefrence)",
            "maxwidth": "1000"
        ]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = queryItems
        let url = components.url!
        print(url)
        return url
    }
    static func fetchPlaces (input: String, latitude: String, longitude: String, completion: @escaping ([Place]?) -> Void) {
        let url = GooglePlacesAPI.googleNearBySearchesURL(input: input, latitude: latitude, longitude: longitude)
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print("we got data!!!")
                print(dataString)
                if let places = places(fromData: data) {
                    print("we got an [Place] with \(places.count) places")
                    DispatchQueue.main.async {
                        completion(places)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            else {
                if let error = errorOptional {
                    print("Error getting data \(error)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    static func fetchPlaceDetails (placeID: String, completion: @escaping (PlaceDetails?) -> Void) {
        let url = GooglePlacesAPI.googlePlaceDetailsURL(placeID: placeID)
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print("we got data!!!")
                print(dataString)
                if let places = details(fromData: data) {
                    print("we got an [Place] with places")
                    DispatchQueue.main.async {
                        completion(places)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            else {
                if let error = errorOptional {
                    print("Error getting data \(error)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    static func fetchPlacePhoto (fromURLString urlString: String, completion: @escaping (UIImage?) -> Void) {
        let url = GooglePlacesAPI.googlePlacePhotosURL(photoRefrence: urlString)
           let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
               if let data = dataOptional, let image = UIImage(data: data) {
                   DispatchQueue.main.async {
                       completion(image)
                   }
               }
               else {
                   if let error = errorOptional {
                       print("error fetching image \(error)")
                   }
                   DispatchQueue.main.async {
                       completion(nil)
                   }
               }
           }
           task.resume()
       }
    
    static func places (fromData data: Data) -> [Place]? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let placesArray = jsonDictionary["results"] as? [[String: Any]] else {
                print("Error parsing JSON")
                return nil
            }
            print("successfully got placesArray")
            var places = [Place]()
            for placeObject in placesArray {
                if let place = place(fromJSON: placeObject) {
                    places.append(place)
                }
            }
            if !places.isEmpty {
                return places
            }
        }
        catch {
            print("Error converting Data to JSON \(error)")
        }
        
        return nil
    }
    
    static func details (fromData data: Data) -> PlaceDetails? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let detailArray = jsonDictionary["result"] as? [String: Any] else {
                print("Error parsing JSON")
                return nil
            }
            print("successfully got details")
            //var details = PlaceDetails
            if let detail = detail(fromJSON: detailArray) {
                //details.append(detail)
                return detail
            }
        }
        catch {
            print("Error converting Data to JSON \(error)")
        }
        
        return nil
    }
    
    static func photos (fromData data: Data) -> [PlacePhoto]? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let photoArray = jsonDictionary["photos"] as? [[String: Any]] else {
                print("Error parsing JSON")
                return nil
            }
            print("successfully got photoArray")
            var photos = [PlacePhoto]()
            for photosObject in photoArray {
                if let photo = photo(fromJSON: photosObject) {
                    photos.append(photo)
                }
            }
            if !photos.isEmpty {
                return photos
            }
        }
        catch {
            print("Error converting Data to JSON \(error)")
        }
        
        return nil
    }
    
    
    
    static func place (fromJSON jsonPlace: [String: Any]) -> Place? {
        guard let id = jsonPlace["place_id"] as? String else {
            return Place(ID: "", name: "", vicinity: "", rating: "", photoRefrence: "", openingHours: "")
        }
        
        guard let name = jsonPlace["name"] as? String else {
            return Place(ID: id.description, name: "", vicinity: "", rating: "", photoRefrence: "", openingHours: "")
        }
        
        guard let vicinity = jsonPlace["vicinity"] as? String else {
            return Place(ID: id.description, name: name.description, vicinity: "", rating: "", photoRefrence: "", openingHours: "")
        }
        
        guard let rating = jsonPlace["rating"] as? Double else {
            return Place(ID: id.description, name: name.description, vicinity: vicinity.description, rating: "", photoRefrence: "", openingHours: "")
        }
        
        guard let hours = jsonPlace["opening_hours"] as? [String: Any] else {
            return Place(ID: id.description, name: name.description, vicinity: vicinity.description, rating: rating.description, photoRefrence: "", openingHours: "")
        }
        
        guard let openNow = hours["open_now"] as? Bool else {
            return Place(ID: id.description, name: name.description, vicinity: vicinity.description, rating: rating.description, photoRefrence: "", openingHours: "")
        }
        
        guard let photoArray = jsonPlace["photos"] as? [[String: Any]] else {
            return Place(ID: id.description, name: name.description, vicinity: vicinity.description, rating: rating.description, photoRefrence: "", openingHours: openNow.description)
        }
        guard let photo = photoArray.first else {
            return Place(ID: id.description, name: name.description, vicinity: vicinity.description, rating: rating.description, photoRefrence: "", openingHours: openNow.description)
        }
        
        guard let photoURL = photo["photo_reference"] as? String else {
            return Place(ID: id.description, name: name.description, vicinity: vicinity.description, rating: rating.description, photoRefrence: "", openingHours: openNow.description)
        }
        
        return Place(ID: id.description, name: name.description, vicinity: vicinity.description, rating: rating.description, photoRefrence: photoURL.description, openingHours: openNow.description)
        
        
    }
    
    static func detail (fromJSON jsonDetail: [String: Any]) -> PlaceDetails? {
        guard let address = jsonDetail["formatted_address"] as? String else {
            return PlaceDetails(formattedPhoneNumber: "", formattedAddress: "", review: "")
        }
        
        guard let phoneNumber = jsonDetail["formatted_phone_number"] as? String else {
            return PlaceDetails(formattedPhoneNumber: "", formattedAddress: address.description, review: "")
        }
        
        guard let reviews = jsonDetail["reviews"] as? [[String: Any]] else {
            return PlaceDetails(formattedPhoneNumber: phoneNumber.description, formattedAddress: address.description, review: "")
        }
        guard let review = reviews.first else {
            return PlaceDetails(formattedPhoneNumber: phoneNumber.description, formattedAddress: address.description, review: "")
        }
        
        guard let text = review["text"] as? String else {
            return PlaceDetails(formattedPhoneNumber: phoneNumber.description, formattedAddress: address.description, review: "")
        }
        
        return PlaceDetails(formattedPhoneNumber: phoneNumber.description, formattedAddress: address.description, review: text.description)
    }
    
    static func photo (fromJSON jsonPhotos: [String: Any]) -> PlacePhoto? {
        guard let photoArray = jsonPhotos["photos"] as? [[String: Any]] else { // get photo array to have values
            return PlacePhoto(photos: "", photo_refrence: "")
        }
        
        guard let photoURL = jsonPhotos["photo_reference"] as? String else { // get photo array to have values
            return PlacePhoto(photos: photoArray.description, photo_refrence: "")
        }
        return PlacePhoto(photos: photoArray.description, photo_refrence: photoURL.description)
        
        
    }
    
}
