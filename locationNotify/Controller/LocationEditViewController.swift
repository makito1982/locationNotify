//
//  LocationEditViewController.swift
//  locationNotify
//
//  Created by makito on 2021/01/03.
//

import UIKit
import MapKit

class LocationEditViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var notifySelectControl: UISegmentedControl!
    @IBOutlet weak var radiusTextField: UITextField!
    //radius
    
    var viewLocationItem:LocationDataItem?
    var updateIndex:Int = -1
    var viewlat:Double = -1
    var viewlot:Double = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewLocation = viewLocationItem else {
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: viewLocation.lat, longitude: viewLocation.lot)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = viewLocation.name
        
        var region:MKCoordinateRegion = mapView.region
        region.center = coordinate
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(annotation)
        
        nameTextField.text = viewLocation.name
        addressField.text = viewLocation.adress
        notifySelectControl.selectedSegmentIndex = viewLocation.notifytrigger.rawValue
        radiusTextField.text = String(viewLocation.radius)
        
        viewlot = viewLocation.lot
        viewlat = viewLocation.lat
        
        print("coordinate: \(viewLocation.lat) \(viewLocation.lot)")
    }


    @IBAction func mapViewDidTap(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended{
            let tapPoint = sender.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = ""
            
            mapView.addAnnotation(annotation)
            
            print("tap..")
            print("coordinate: \(coordinate.latitude) \(coordinate.longitude)")
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            viewlot = coordinate.longitude
            viewlat = coordinate.latitude
            
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {
                    return
                }
                self.nameTextField.text = placemark.name
                self.addressField.text = placemark.name
            }
        }
    }
    @IBAction func SaveAction(_ sender: Any) {
        
        let pevVc = self.presentingViewController as! MainDataListViewController
        
        let locationDataItem:LocationDataItem = LocationDataItem()
        
        locationDataItem.lat = viewlat//map.placemark.coordinate.latitude
        locationDataItem.lot = viewlot//map.placemark.coordinate.longitude
        locationDataItem.name = nameTextField.text ?? ""
        locationDataItem.valid = true
        locationDataItem.radius = Double( radiusTextField.text ?? "" ) ?? 0
        locationDataItem.SetNotifyTrigger(notifytrigger: LocationDataItem.notifyTrigger(rawValue: notifySelectControl.selectedSegmentIndex) ?? LocationDataItem.notifyTrigger.both)
        locationDataItem.adress = addressField.text ?? ""
        
        pevVc.locationData.dataItem?[updateIndex] = locationDataItem
        pevVc.locationData.savedata()
        pevVc.tableView.reloadData()
        
        // この画面を閉じる
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func DeleteAction(_ sender: Any) {
        let pevVc = self.presentingViewController as! MainDataListViewController
        

        pevVc.locationData.dataItem?.remove(at: updateIndex)
        pevVc.locationData.savedata()
        pevVc.tableView.reloadData()
        
        // この画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func CancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
