//
//  LocationData.swift
//  locationNotify
//
//  Created by makito on 2020/12/26.
//

import Foundation


class LocationDataItem : Codable {
    var lot:Double = 0   //位置
    var lat:Double = 0   //位置
    var valid:Bool = true//有効無効
    var radius:Double = 100.0 //通知範囲
    var onEntry:Bool = false //通知トリガー(入るとき)
    var onExit:Bool = false  //通知トリガー(出るとき)
    var notifytrigger:notifyTrigger = .both
    var name:String = ""    //名前
    var adress:String = ""  //住所
    
    
    
 /*
    func encode(with coder: NSCoder) {
        coder.encode(lot,forKey: "lot")
        coder.encode(lat,forKey: "lat")
        coder.encode(name,forKey: "name")
        coder.encode(radius,forKey: "radius")
        coder.encode(notifytrigger,forKey: "notifytrigger")
    }
    
    required init?(coder: NSCoder) {
        self.lot = coder.decodeObject(forKey: "lot") as? Double ?? 0
        self.lat = coder.decodeObject(forKey: "lat") as? Double ?? 0
        self.name = coder.decodeObject(forKey: "name") as? String ?? ""
        self.radius = coder.decodeObject(forKey: "radius") as? Double ?? 0
        self.notifytrigger = coder.decodeObject(forKey: "notifytrigger") as? notifyTrigger ?? notifyTrigger.both
    }*/
    
    enum notifyTrigger:Int,Codable {
        case entry = 0
        case exit = 1
        case both = 2
    }
    
    func SetNotifyTrigger(notifytrigger:notifyTrigger){
        self.notifytrigger = notifytrigger
        
        switch notifytrigger {
        case .entry:
            onExit = true
            onEntry = false
        case .exit://到着時
            onExit = false
            onEntry = true
        case .both://両方
            onExit = true
            onEntry = true
        }
    }
}

class LocationData{
    var dataItem:[LocationDataItem]?
    
    init(){
        if let getdata = UserDefaults.standard.object(forKey: "dataitem") as? Data {
            //if let unarchivedObject = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(getdata) as? [LocationDataItem]{
            if let unarchivedObject = try! JSONDecoder().decode([LocationDataItem].self, from: getdata) as? [LocationDataItem]{
                    self.dataItem = unarchivedObject
            }
        }
        
    }
    
    func savedata(){
        //UserDefaults.standard.set(dataItem as [any], forKey: "dataitem")
        guard let savedata = dataItem else {
            return
        }
        //let archiveData = try! NSKeyedArchiver.archivedData(withRootObject: savedata, requiringSecureCoding: false)
        let archiveData = try? JSONEncoder().encode(savedata)
        UserDefaults.standard.set(archiveData, forKey: "dataitem")
    }
    
    func addDataItem(item:LocationDataItem){
        if dataItem == nil{
            dataItem = [item]
        }else{
            dataItem?.append(item)
        }
    }
}
