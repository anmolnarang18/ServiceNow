//
//  homeVCViewController.swift
//  ServiceNow
//
//  Created by Anmol Narang on 14/04/23.
//

import UIKit
import SVProgressHUD
import CoreLocation
import MarqueeLabel
import SwiftyJSON
import CoreLocation


class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
//    var serviceArray = [services]()
    var serviceList: [services] = []
    var favoriteList: [services] = []
    var imageCollection = ["slideService1","slideService2","slideService3"]
    
  
    
    @IBOutlet weak var lblLocation: MarqueeLabel!
    
    @IBOutlet weak var sortingSwitch: UISwitch!
    @IBOutlet weak var sortingView: UIView!
    @IBOutlet weak var sortingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lblNoService: UILabel!
    @IBOutlet weak var favImage: UIImageView!
    @IBOutlet weak var favTitle: UILabel!
    
    @IBOutlet weak var serviceTableView: UITableView!{
            didSet{
                self.serviceTableView.register(UINib(nibName: "listViewCell", bundle: nil), forCellReuseIdentifier: "listViewCell")
                self.serviceTableView.dataSource = self
                self.serviceTableView.delegate = self
            }
        }
    @IBOutlet weak var slideShowCV: UICollectionView!{
        didSet{
            self.slideShowCV.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DefaultCell")
            self.slideShowCV.dataSource = self
            self.slideShowCV.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        checkUser()
        getServices()
        getLocationAddress()
        self.slideShowCV.reloadData()
        self.serviceTableView.reloadData()
        sortingSwitch.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged)
    }
    func noServicesView(){
        if serviceList.isEmpty{
            self.lblNoService.isHidden = false
        }else{
            self.lblNoService.isHidden = true
        }
    }
    @objc func switchValueDidChange() {
        if sortingSwitch.isOn{
        serviceList.sort { $0.price < $1.price }
        self.serviceTableView.reloadData()
        }else{
            serviceList.sort { $0.distance < $1.distance }
            self.serviceTableView.reloadData()
        }
    }
    func checkUser(){
        if isSP{
            self.favImage.image = UIImage(systemName: "plus")
            self.favTitle.text = "Add"
            self.sortingView.isHidden = true
            self.sortingViewHeight.constant = 0
        }
    }
    
    @IBAction func onFav(_ sender: Any) {
        if isSP{
            let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "addNewServiceVC") as! addNewServiceVC
            self.navigationController?.pushViewController(vcStoreList, animated: true)
        }else{
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "FavoriteVC") as! FavoriteVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
        }
    }
    @IBAction func onMyOrder(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "MyOrderVC") as! MyOrderVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    @IBAction func onMyProfile(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    
    @IBAction func onLocation(_ sender: Any) {
        let vcSearchMap = self.storyboard?.instantiateViewController(withIdentifier: "SearchMapVC") as! SearchMapVC
        vcSearchMap.latitude = userlat
        vcSearchMap.longitude = userlong
        vcSearchMap.searchCallBack = { (latitude, longitude, address, screenType) in
            userlat = latitude
            userlong = longitude
            self.lblLocation.text = address
            currentAddress = address
            let updateAddreess:[String : Any] = ["latitude": "\(latitude)", "longitude":"\(longitude)", "address":address]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationUpdateNotification"), object: nil, userInfo: updateAddreess)
            self.getServices()
            self.switchValueDidChange()
        }
        self.present(vcSearchMap, animated: true, completion: nil)
    }
    func getLocationAddress() {
        //print("10")
        SVProgressHUD.show()
        
        updatedCoordinates.latitude = userlat
        updatedCoordinates.longitude = userlong
        
//        let language = Localize.currentLang()
        let lang = localLanguage
//        if language == .arabic {
//            lang = localLanguage
//        }
        let url =  "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(userlat),\(userlong)&key=\(Keys.googleKey)&language=\(lang)&sensor=true"
        
        TrackOrderModel.sendRequestToServer(baseUrl: url, "", httpMethod: "POST", isZipped: false) { (isSuccess, response) in
            if let address = response["results"] as? [[String: Any]], let data = address.first, let formatedAddess = data["formatted_address"] as? String {
                DispatchQueue.main.async {
                    if "\(self.lblLocation.text!)" == "Getting your current location"{
                    self.lblLocation.text = formatedAddess
                    }
                    currentAddress = formatedAddess
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func getServices(){
        SVProgressHUD.show()
        var param: [String: Any] = [:]
        if !isSP{
            param["isAll"] = true
        }
        
        
        let url = API.getServices
        
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(response)
                DispatchQueue.main.async {
                    let json = JSON(response["data"])
                    if !self.serviceList.isEmpty{
                        self.serviceList.removeAll()
                    }
                    for item in 0..<json.count{
                        let p = services(fromDictionary:json[item].dictionaryObject!)
                        print(p)
                        self.serviceList.append(p)
                    }
                    self.serviceList.sort { $0.price < $1.price }
                    if !isSP{
                    self.getFavorites()
                    }else{
                        self.noServicesView()
                        self.serviceTableView.reloadData()
                    }
                    if !self.serviceList.isEmpty{
                    for item in 0...self.serviceList.count-1{
                        self.serviceList[item].distance = self.calculateDistance(serv: self.serviceList[item])
                    }
                    }
                }
//                showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: false)
                SVProgressHUD.dismiss()
        }
    }
    func getFavorites(){
        SVProgressHUD.show()
        var param: [String: Any] = [:]
        param["isAll"] = false
        
        let url = API.getFav
        print(url)
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(response)
            let result = JSON(response["data"]!)
             let json = result
                DispatchQueue.main.async {
                    if !self.favoriteList.isEmpty{
                        self.favoriteList.removeAll()
                    }
                    for item in 0..<json.count{
                        let p = services(fromDictionary:json[item].dictionaryObject!)
                        print(p)
                        self.favoriteList.append(p)
                    }
                    if !self.serviceList.isEmpty && !self.favoriteList.isEmpty{
                    for item in 0...self.serviceList.count-1{
                        let check = self.favoriteList.contains(where: {$0.serviceID == self.serviceList[item].serviceID})
                        if check{
                            self.serviceList[item].isFavorite = 1
                        }
                    }
                    }
                    self.noServicesView()
                    self.serviceTableView.reloadData()
                }
                SVProgressHUD.dismiss()
            }
        }
    func calculateDistance(serv:services)->Double{
        let coordinate₀ = CLLocation(latitude: Double(serv.userLat) ?? 0.0, longitude: Double(serv.userLong) ?? 0.0)
        let coordinate₁ = CLLocation(latitude: userlat, longitude: userlong)

        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        return Double(distanceInMeters)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20 , height: collectionView.frame.height - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainScreenSliderCell", for: indexPath) as! mainScreenSliderCell
        cell.mainImage.image = UIImage(named: imageCollection[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listViewCell", for: indexPath) as! listViewCell
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.serviceTitle.text = serviceList[indexPath.row].serviceName
        cell.companyName.text = serviceList[indexPath.row].companyName
        cell.storeLocation.text = serviceList[indexPath.row].address
        cell.serviceDesc.text = serviceList[indexPath.row].description
        cell.servicePrice.text = "$\(serviceList[indexPath.row].price ?? 0.0)"
        cell.postedDate.text = dateFormatter(date: serviceList[indexPath.row].createdAt)
        cell.btnPhone.addTarget(self, action: #selector(onMakeCall(_:)), for: .touchUpInside)
        cell.btnShare.addTarget(self, action: #selector(onShare(_:)), for: .touchUpInside)
        cell.btnFav.addTarget(self, action: #selector(onFavorite(_:)), for: .touchUpInside)
        cell.btnPhone.tag = indexPath.row
        cell.btnShare.tag = indexPath.row
        cell.btnFav.tag = indexPath.row
        
        if isSP{
            cell.btnFav.isHidden = true
            cell.btnPhone.isHidden = true
        }else{
            if serviceList[indexPath.row].isFavorite == 0{
                cell.btnFav.setImage(UIImage(systemName: "heart"), for: .normal)
            }else{
                cell.btnFav.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "ServiceDetailsVC") as! ServiceDetailsVC
        vcStoreList.currentService = serviceList[indexPath.row]
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !isSP{
            return nil
        }else{
            let deleteAction = UIContextualAction(style: .normal, title: "") { (context, view, result) in
                self.deleteService(sID: self.serviceList[indexPath.row].serviceID)
                self.noServicesView()
            }
            
            deleteAction.image = UIImage(named: "ic_delete")
            deleteAction.backgroundColor = .white
            
            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            config.performsFirstActionWithFullSwipe = false
            
            return config
        }
    }
    
    @objc func onMakeCall(_ sender:UIButton){
        callNumber(phoneNumber: serviceList[sender.tag].phoneNumber.clean)
    }
    @objc func onFavorite(_ sender:UIButton){
        SVProgressHUD.show()
        var param: [String: Any] = [:]
        param["serviceID"] = serviceList[sender.tag].serviceID
        param["serviceName"] = serviceList[sender.tag].serviceName
        param["companyName"] = serviceList[sender.tag].companyName
        param["address"] = serviceList[sender.tag].address
        param["price"] = serviceList[sender.tag].price
        param["description"] = serviceList[sender.tag].description
        param["phoneNumber"] = serviceList[sender.tag].phoneNumber
        param["startTime"] = serviceList[sender.tag].startTime
        param["endTime"] = serviceList[sender.tag].endTime
        param["userLong"] = serviceList[sender.tag].userLat
        param["userLat"] = serviceList[sender.tag].userLong
     
        
        let url = API.addToFav
        
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(response)
            if let json = response["data"] as? [String: Any]{
                DispatchQueue.main.async {
                    showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: false)
                    self.getServices()
                    SVProgressHUD.dismiss()
                }
            }else{
                showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: false)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @objc func onShare(_ sender:UIButton){
        let item = sender.tag
        let text = "Check This Out\nService Name: \(serviceList[item].serviceName!)\nCompany Name: \(serviceList[item].companyName!)\nAddress: \(serviceList[item].address!)\nPhoneNumber: \(serviceList[item].phoneNumber!)\nDescription: \(serviceList[item].description!)"
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func deleteService(sID:Int){
        SVProgressHUD.show()
        var param: [String: Any] = [:]
        param["service_ID"] = sID
     
        
        let url = API.deleteService
        
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(response)
            if let json = response["data"] as? [String: Any]{
                DispatchQueue.main.async {
                    self.getServices()
                    SVProgressHUD.dismiss()
                }
            }else{
                showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: false)
                SVProgressHUD.dismiss()
            }
        }
    }



}
