//
//  ViewController.swift
//  locationNotify
//
//  Created by makito on 2020/11/29.
//

import UIKit
import MapKit

class LocationSearchViewController: UIViewController, UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {


    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notifySelectSegment: UISegmentedControl!
    
    @IBOutlet weak var radiusTextField: UITextField!
    
    var mapItems:[MKMapItem]?
    var selectedrow:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        radiusTextField.text = "100.0"
        
        mapView.showsUserLocation = true
    }

    
    
    /// テキストボックスのEnter押下したとき
    /// - Parameter textField: 対象テキストボックス
    /// - Returns: Tureを返す(閉じる)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        mapView.removeAnnotations(mapView.annotations)
        
        let region:MKCoordinateRegion? = nil
        if let searchKey = textField.text {
            
            Map.search(query: searchKey, region: region) { (result) in
                switch result {
                case .success(let mapItems):
                    self.mapItems = mapItems
                    
                    for map in mapItems {
                        print("name: \(map.name ?? "no name")")
                        print("coordinate: \(map.placemark.coordinate.latitude) \(map.placemark.coordinate.latitude)")
                        print("address \(map.placemark.address)")
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = map.placemark.coordinate
                        annotation.title = map.name ?? "名前がありません"
                        self.mapView.addAnnotation(annotation)
                    }
                case .failure(let error):
                    print("error \(error.localizedDescription)")
                }
                
                self.tableView.reloadData()
            }
        }

       return true
    }
    struct Map {
        enum Result<T> {
            case success(T)
            case failure(Error)
        }

        static func search(query: String, region: MKCoordinateRegion? = nil, completionHandler: @escaping (Result<[MKMapItem]>) -> Void) {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query

            if let region = region {
                request.region = region
            }

            MKLocalSearch(request: request).start { (response, error) in
                if let error = error {
                    completionHandler(.failure(error))
                    return
                }
                completionHandler(.success(response?.mapItems ?? []))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let locationLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        if let map = mapItems?[indexPath.row] {
            nameLabel.text = map.name
            locationLabel.text = map.placemark.address
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedrow = indexPath.row
    }
    
    /// 保存ボタン押したとき
    /// - Parameter sender: <#sender description#>
    @IBAction func SaveAction(_ sender: Any) {
        //TableViewで未選択は抜ける
        guard let selectRow = selectedrow  else {
            return
        }
        
        guard let map = mapItems?[selectRow] else {
            return
        }
        guard let radius = Double(radiusTextField.text!) else {
            return
        }
        var locationDataItem:LocationDataItem = LocationDataItem()
        
        locationDataItem.lat = map.placemark.coordinate.latitude
        locationDataItem.lot = map.placemark.coordinate.longitude
        locationDataItem.name = map.name!
        locationDataItem.valid = true
        locationDataItem.radius = radius
        locationDataItem.SetNotifyTrigger(notifytrigger: LocationDataItem.notifyTrigger(rawValue: notifySelectSegment.selectedSegmentIndex) ?? LocationDataItem.notifyTrigger.both)
        locationDataItem.adress = map.placemark.address
        #if false
        switch notifySelectSegment.selectedSegmentIndex {
        case 0://出発時
            locationDataItem.onExit = true
            locationDataItem.onEntry = false
        case 1://到着時
            locationDataItem.onExit = false
            locationDataItem.onEntry = true
        case 2://両方
            locationDataItem.onExit = true
            locationDataItem.onEntry = true
        default:
            break
        }
        #endif
        
        
        //TableViewで選択されているものを保存する
        let pevVc = self.presentingViewController as! MainDataListViewController
        
        pevVc.locationData.addDataItem(item: locationDataItem)
        //pevVc.locationData.dataItem?.append(locationDataItem)
        pevVc.locationData.savedata()
        pevVc.tableView.reloadData()
        
        // この画面を閉じる
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    /// キャンセルボタンを押したとき
    /// - Parameter sender:
    @IBAction func CancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
extension MKPlacemark {
    var address: String {
        let components = [self.administrativeArea, self.locality, self.thoroughfare, self.subThoroughfare]
        return components.compactMap { $0 }.joined(separator: "")
    }
}
