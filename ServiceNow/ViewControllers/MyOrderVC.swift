//
//  MyOrderVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class MyOrderVC: UIViewController {

    var serviceList: [services] = []
    @IBOutlet weak var favImage: UIImageView!
    @IBOutlet weak var favTitle: UILabel!
    @IBOutlet weak var lblNoOrders: UILabel!
    @IBOutlet weak var serviceTableView: UITableView!{
        didSet{
            self.serviceTableView.register(UINib(nibName: "listViewCell", bundle: nil), forCellReuseIdentifier: "listViewCell")
            self.serviceTableView.dataSource = self
            self.serviceTableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        checkUser()
        getOrders()
    }
    func noOrdersView(){
        if serviceList.isEmpty{
            self.lblNoOrders.isHidden = false
        }else{
            self.lblNoOrders.isHidden = true
        }
    }
    func checkUser(){
        if isSP{
            self.favImage.image = UIImage(systemName: "plus")
            self.favTitle.text = "Add"
        }
    }
    
    func getOrders(){
        SVProgressHUD.show()
        var param: [String: Any] = [:]
        param["isAll"] = false
        
        var url = ""
        if isSP{
        url = API.getOrdersForCreator
            let userData = getJSON("isUserLogin")
            let creator = userData?["_id"].stringValue
    param["serviceCreator"] = creator
        }else{
        url = API.getOrders
        }
        print(url)
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(response)
            let result = JSON(response["data"]!)
             let json = result
                DispatchQueue.main.async {
                    if !self.serviceList.isEmpty{
                        self.serviceList.removeAll()
                    }
                    for item in 0..<json.count{
                        let p = services(fromDictionary:json[item].dictionaryObject!)
                        print(p)
                        self.serviceList.append(p)
                        self.serviceTableView.reloadData()
                        self.noOrdersView()
                    }
                }
//            }else{
//                showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: false)
                SVProgressHUD.dismiss()
            }
        }

    
    @IBAction func onHome(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
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
    @IBAction func onMyProfile(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }

}
extension MyOrderVC: UITableViewDataSource, UITableViewDelegate {
    
    
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
        cell.btnPhone.addTarget(self, action: #selector(onMakeCall(_:)), for: .touchUpInside)
        cell.btnShare.addTarget(self, action: #selector(onShare(_:)), for: .touchUpInside)
        cell.btnPhone.tag = indexPath.row
        cell.btnShare.tag = indexPath.row
        cell.btnFav.isHidden = true

        if isSP{
                        cell.lblStatus.isHidden = false
           if serviceList[indexPath.row].status == 0{
                cell.lblStatus.text = "Accepted"
            } else{
                cell.lblStatus.text = "Requested"
            }
        }else{
//            if serviceArray[indexPath.row].isFavorite == 0{
//                cell.btnFav.setImage(UIImage(systemName: "heart"), for: .normal)
//            }else{
//                cell.btnFav.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "ServiceDetailsVC") as! ServiceDetailsVC
        vcStoreList.fromMyOrder = true
        vcStoreList.currentService = serviceList[indexPath.row]
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !isSP{
            let deleteAction = UIContextualAction(style: .normal, title: "") {(context, view, result) in
                self.deleteService(sID: self.serviceList[indexPath.row].orderID ?? 0)
                self.serviceTableView.reloadData()
                self.noOrdersView()
            }
            
            deleteAction.image = UIImage(named: "ic_delete")
            deleteAction.backgroundColor = .white
            
            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            config.performsFirstActionWithFullSwipe = false
            
            return config
        }else{
            return nil
        }
    }
    @objc func onMakeCall(_ sender:UIButton){
        callNumber(phoneNumber: serviceList[sender.tag].phoneNumber.clean)
    }
    @objc func onShare(_ sender:UIButton){
        let item = sender.tag
        let text = "Check This Out\nService Name: \(serviceList[item].serviceName!)\nCompany Name: \(serviceList[item].companyName!)\nPhoneNumber: \(serviceList[item].phoneNumber!)\nDescription: \(serviceList[item].description!)"
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    func deleteService(sID:Int){
        SVProgressHUD.show()
        var param: [String: Any] = [:]
        param["orderID"] = sID
     
        
        let url = API.deleteService
        
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(response)
            if let json = response["data"] as? [String: Any]{
                DispatchQueue.main.async {
                    self.getOrders()
                    SVProgressHUD.dismiss()
                }
            }else{
                showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: false)
                SVProgressHUD.dismiss()
            }
        }
    }
}
