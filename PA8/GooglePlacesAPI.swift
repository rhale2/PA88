//
//  GooglePlacesAPI.swift
//  PA8
//
//  Created by Sophia Braun on 12/6/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
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
        return url
        
    }
    
    
    static func googlePlaceDetailsURL (placeID: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/details/json?"
        
        let params = [
            "key": GooglePlacesAPI.apiKey,
            "place_id": "\(placeID)",
            "fields": "place_id,name,vicinity,rating,photos[]"
        ]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = queryItems
        let url = components.url!
        return url
    }
    
    
    static func googlePlacePhotosURL (photoRefrence: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/photo?"
        
        let params = [
            "key": GooglePlacesAPI.apiKey,
            "photoreference": "\(photoRefrence)",
            "maxwidth": "1600"
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
    
    static func fetchPlaces (input: String, latitude: String, longitude: String) -> [Place]? {
        var place = [Place]()
        let url = GooglePlacesAPI.googleNearBySearchesURL(input: input, latitude: latitude, longitude: longitude)
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print("we got data!!!")
                print(dataString)
                if let places = places(fromData: data) {
                    print("we got an [Place] with \(places.count) places")
                    place = places
                }
            }
            else {
                if let error = errorOptional {
                    print("Error getting data \(error)")
                }
            }
        }
        task.resume()
        return place
    }
    
    static func fetchPlaceImage (photoRefrence: String) -> Data {
        var imageData = Data()
        let url = GooglePlacesAPI.googlePlacePhotosURL(photoRefrence: photoRefrence)
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print("we got data!!!")
                print(dataString)
                imageData = data
            }
            else {
                if let error = errorOptional {
                    print("Error getting data \(error)")
                }
            }
        }
        task.resume()
        return imageData
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
    
    static func photos (fromData data: Data) -> [[String: Any]] {
        var photos: [[String: Any]] = [[:]]
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let photoArray = jsonDictionary["photos"] as? [[String: Any]] else {
                print("Error parsing JSON")
                return photos
            }
            photos = photoArray
            print("successfully got photoArray")
        }
        catch {
            print("Error converting Data to JSON \(error)")
        }
        
        return photos
    }
    
    static func place (fromJSON jsonPlace: [String: Any]) -> Place? {
        guard let id = jsonPlace["place_id"] as? String, let name = jsonPlace["name"] as? String, let vicinity = jsonPlace["vicinity"] as? String, let rating = jsonPlace["rating"] as? Int, let photoArray = jsonPlace["photos"] as? [[String: Any]] else { // get photo array to have values 
            return nil
        }
        print(photoArray)
        return Place(ID: id.description, name: name.description, vicinity: vicinity.description, rating: rating.description, photoRefrence: photoArray.description)
    }
    
}
