//
//  LocationNotifycation.swift
//  locationNotify
//
//  Created by makito on 2021/01/01.
//

import Foundation
import CoreLocation
import UIKit

class LocationNotifycation {
    
    var locationManager:CLLocationManager!
    
    func setNotifycation(item:LocationDataItem){

        let lat = item.lat
        let log = item.lot
        
        let content = UNMutableNotificationContent()
        content.title = item.name
        content.subtitle = ""
        content.body = item.name + "の境界を超えました"
        content.sound = UNNotificationSound.default
        
        let identifier = item.name
        let coordinate = CLLocationCoordinate2DMake(lat , log )
        let region = CLCircularRegion(center: coordinate, radius: item.radius, identifier: identifier)
        region.notifyOnExit = item.onExit
        region.notifyOnEntry = item.onEntry
        let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)

        let locationRequest = UNNotificationRequest(identifier: identifier,
                                                 content: content,
                                                 trigger: locationTrigger)
        UNUserNotificationCenter.current().add(locationRequest, withCompletionHandler: nil)

    }
}
