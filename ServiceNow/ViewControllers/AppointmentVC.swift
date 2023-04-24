//
//  AppointmentVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit
import SVProgressHUD
import SwiftyJSON
import SkyFloatingLabelTextField

class AppointmentVC: BottomPopupViewController {
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    var currentService = services()

    @IBOutlet weak var phoneNumerTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var serviceDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceDatePicker.minimumDate = Date()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBook(_ sender: Any) {
        DispatchQueue.main.async {
            self.createBooking()
        }
    }
    
    func createBooking(){
        SVProgressHUD.show()
        var param: [String: Any] = [:]
        param["serviceName"] = currentService.serviceName
        param["description"] = currentService.description
        param["companyName"] = currentService.companyName
        param["price"] = currentService.price
        param["phoneNumber"] = phoneNumerTxt.text ?? ""
        param["serviceCreator"] = currentService.createdBy
        param["address"] = currentService.address
        
        let userData = getJSON("isUserLogin")
        param["customerName"] = userData?["name"].stringValue
     
        let endNow = serviceDatePicker.date
        let dateComponent = Calendar.current.dateComponents([.hour, .minute], from: endNow)
        let endTimeString = "\(dateComponent.hour ?? 0):\(dateComponent.minute ?? 0)"
        
        param["bookedTime"] = endTimeString
        param["bookedDate"] = "\(endNow)"
        
        let url = API.createOrder
        
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(response)
            if let json = response["data"] as? [String: Any]{
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: true)
                    SVProgressHUD.dismiss()
                }
            }else{
                DispatchQueue.main.async {
                      self.dismiss(animated: true, completion: nil)
                }
                showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: false)
                SVProgressHUD.dismiss()
            }
        }
    }
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override var popupTopCornerRadius: CGFloat { return topCornerRadius ?? CGFloat(10) }
    
    override var popupPresentDuration: Double { return presentDuration ?? 1.0 }
    
    override var popupDismissDuration: Double { return dismissDuration ?? 1.0 }
    
    override var popupShouldDismissInteractivelty: Bool { return shouldDismissInteractivelty ?? true }

}
