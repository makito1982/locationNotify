//
//  MainDataListViewController.swift
//  locationNotify
//
//  Created by makito on 2020/12/26.
//

import UIKit
import CoreLocation

class MainDataListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UNUserNotificationCenterDelegate {

    var locationData:LocationData = LocationData()
    var locationManager:CLLocationManager!
    var locationNotify:LocationNotifycation = LocationNotifycation()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 55
        
        // 通知許可の取得
        UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]){
            (granted, _) in
            if granted{
                UNUserNotificationCenter.current().delegate = self
            }
        }
        let center = UNUserNotificationCenter.current()

        // 通知の使用許可をリクエスト
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }
        
        setupLocationManager()
        
        
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()

        // 権限をリクエスト
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()

        // マネージャの設定
        //let status = CLLocationManager.authorizationStatus()

        // ステータスごとの処理
        //if status == .authorizedWhenInUse {
        //    locationManager.delegate = self
         //   locationManager.startUpdatingLocation()
        //}
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationData.dataItem?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let locationLabel = cell.contentView.viewWithTag(2) as! UILabel
        let notifyLabel = cell.contentView.viewWithTag(3) as! UILabel
        let radiusLabel = cell.contentView.viewWithTag(4) as! UILabel
        
        if let location = locationData.dataItem?[indexPath.row] {
            nameLabel.text = location.name
            locationLabel.text = location.adress
            //notifyLabel.text = ""
            radiusLabel.text = String(location.radius) + "m"
            
            switch location.notifytrigger {
            case .entry:
                notifyLabel.text = "出発時"
            case .exit:
                notifyLabel.text = "到着時"
            case .both:
                notifyLabel.text = "出発到着"
            }
            
            locationNotify.setNotifycation(item: location)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toEdit", sender:  indexPath)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            let editVc = segue.destination as! LocationEditViewController
            if let indexpath = sender as? IndexPath {
                editVc.viewLocationItem = locationData.dataItem?[indexpath.row]
                editVc.updateIndex = indexpath.row
            }
        }
    }
    @IBAction func AddAction(_ sender: Any) {
        performSegue(withIdentifier: "toSetting", sender: nil)
    }
    
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // アプリ起動時も通知を行う
        completionHandler([ .badge, .sound, .list, .banner ])
    }
}
