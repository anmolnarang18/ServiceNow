//
//  serviceDetailsVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class ServiceDetailsVC: UIViewController, BottomPopupDelegate {

    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var lblCompanyTitle: UILabel!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewDescription: UIView!
    
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblTimingTitle: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTimings: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnBook: UIButton!
    
    var fromMyOrder = false
    var currentService = services()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setData()
        userCheck()
    }
    func setData(){
        self.lblServiceName.text = currentService.serviceName
        self.lblCompanyName.text = currentService.companyName
        self.lblLocation.text = currentService.address
        self.lblDate.text = dateFormatter(date: currentService.createdAt)
        self.lblPrice.text = "$\(currentService.price ?? 0.0)"
        self.lblDesc.text = currentService.description
        if fromMyOrder{
            self.lblTimings.text = currentService.bookedTime
        }else{
            self.lblTimings.text = currentService.startTime + "-" + currentService.endTime
        }
        if currentService.status == 1 && !fromMyOrder{
            self.lblStatus.text = "Requested"
            self.statusView.isHidden = false
            self.bottomViewHeight.constant = 0
            
        }else if currentService.status == 0 {
            self.lblStatus.text = "Accepted"
            self.statusView.isHidden = false
            self.bottomViewHeight.constant = 0
        }
    }
    func userCheck(){
        if isSP{
            if fromMyOrder{
                if currentService.status == 1{
                    self.lblServiceName.text = currentService.customerName
                    self.lblServiceTitle.text = "Customer : "
                    self.lblCompanyTitle.text = "Phone : "
                    let phNo = currentService.phoneNumber.clean
                    self.lblCompanyName.text = phNo
                    lblCompanyName.isUserInteractionEnabled = true
                    let guestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(numberClicked(_:)))
                    lblCompanyName.addGestureRecognizer(guestureRecognizer)
                    self.viewLocation.isHidden = true
                    self.viewDescription.isHidden = true
                    
                self.btnBook.setTitle("Accept Appointment", for: .normal)
                    self.btnBook.setImage(nil, for: .normal)
                    self.statusView.isHidden = true
                }else{
                    self.lblServiceName.text = currentService.customerName
                    self.lblServiceTitle.text = "Customer : "
                    self.lblCompanyTitle.text = "Phone : "
                    let phNo = currentService.phoneNumber.clean
                    self.lblCompanyName.text = phNo
                    lblCompanyName.isUserInteractionEnabled = true
                    let guestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(numberClicked(_:)))
                    lblCompanyName.addGestureRecognizer(guestureRecognizer)
                    
                    self.viewLocation.isHidden = true
                    self.viewDescription.isHidden = true
                    self.bottomViewHeight.constant = 0
                    self.statusView.isHidden = false
                    if currentService.status == 1{
                    lblStatus.text = "Requested"
                    }else{
                    lblStatus.text = "Accepted"
                    }
                }
                self.lblDateTitle.text = "Selected Date : "
                self.lblTimingTitle.text = "Selected Time : "
            }else{
                self.bottomViewHeight.constant = 0
            }
        }else{
            if fromMyOrder{
                self.bottomViewHeight.constant = 0
                self.statusView.isHidden = false
                self.lblDateTitle.text = "Selected Date"
                self.lblTimingTitle.text = "Selected Time"
                if currentService.status == 1{
                lblStatus.text = "Requested"
                }else{
                lblStatus.text = "Accepted"
                }
            }else{
                if currentService.status == 2{
                self.statusView.isHidden = true
                }else if  currentService.status == 1{
                    self.bottomViewHeight.constant = 0
                    self.statusView.isHidden = false
                    lblStatus.text = "Requested"
                }else{
                    self.bottomViewHeight.constant = 0
                    self.statusView.isHidden = false
                    lblStatus.text = "Accepted"
                }
            }
        }
    }
    
    @objc func numberClicked(_ sender: Any){
        callNumber(phoneNumber: currentService.phoneNumber.clean)
    }
    
    @IBAction func onBook(_ sender: Any) {
        if isSP{
          updateBooking()
        }else{
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "AppointmentVC") as! AppointmentVC
        vcStoreList.shouldDismissInteractivelty = false
        vcStoreList.currentService = currentService
        vcStoreList.popupDelegate = self
        vcStoreList.topCornerRadius = 10
        vcStoreList.presentDuration = 0.30
        vcStoreList.dismissDuration = 0.30
        self.present(vcStoreList, animated: true, completion: nil)
        }
    }
    @IBAction func onBack(_ sender: Any) {
        _=navigationController?.popViewController(animated: true)
    }
    
    func updateBooking(){
        SVProgressHUD.show()
        var param: [String: Any] = [:]
        param["order_ID"] = currentService.orderID
     
        
        let url = API.updateOrder
        
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(response)
            if let json = response["data"] as? [String: Any]{
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.currentService.status = 2
                    self.userCheck()
                    self.setData()
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
