//
//  addNewServiceVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftyJSON
import SVProgressHUD

class addNewServiceVC: UIViewController {

    
    @IBOutlet weak var startTime: UIDatePicker!
    @IBOutlet weak var endtime: UIDatePicker!
    @IBOutlet weak var descriptionTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var priceTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var addressTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var companyName: SkyFloatingLabelTextField!
    @IBOutlet weak var serviceName: SkyFloatingLabelTextField!
    @IBOutlet weak var lblLocation: SkyFloatingLabelTextField!
    @IBOutlet weak var phoneNumberTxt: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func onHome(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    @IBAction func onMyProfile(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    @IBAction func onMyOrder(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "MyOrderVC") as! MyOrderVC
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
        }
        self.present(vcSearchMap, animated: true, completion: nil)
    }
    @IBAction func btnAddServices(_ sender: Any) {
        addServicesToBackend()
    }
    
    func addServicesToBackend(){
        SVProgressHUD.show()
//        let startNow = startTime.date
//        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: startNow)
//        let startTimeString = "\(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0)"
//
//        let endNow = startTime.date
//        let dateComponent = Calendar.current.dateComponents([.hour, .minute], from: endNow)
//        let endTimeString = "\(dateComponent.hour ?? 0):\(dateComponent.minute ?? 0)"
        
        
        var param: [String: Any] = [:]
        param["serviceName"] = serviceName.text ?? ""
        param["companyName"] = companyName.text ?? ""
        param["address"] = addressTxt.text ?? ""
        param["price"] = Float(priceTxt.text ?? "")
        param["description"] = descriptionTxt.text ?? ""
        param["phoneNumber"] = phoneNumberTxt.text ?? ""
        param["startTime"] = timeFormatter(date: startTime.date)
        param["endTime"] = timeFormatter(date: endtime.date)
        param["userLong"] = userlong
        param["userLat"] = userlat
        
        let url = API.createService
        print(url)
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(header)
            print(response)
            if let json = response["data"] as? [String: Any]{
                DispatchQueue.main.async {
                    let vcStoreList = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    self.navigationController?.pushViewController(vcStoreList, animated: true)
                    SVProgressHUD.dismiss()
                }
            }else{
                showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: false)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
