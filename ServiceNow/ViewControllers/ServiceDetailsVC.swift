//
//  serviceDetailsVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit

class ServiceDetailsVC: UIViewController, BottomPopupDelegate {

    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
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
        userCheck()
        setData()
        // Do any additional setup after loading the view.
    }
    func setData(){
        self.lblServiceName.text = currentService.title
        self.lblCompanyName.text = currentService.companyName
        self.lblLocation.text = currentService.location
        self.lblDate.text = currentService.postedDate
        self.lblPrice.text = "$\(currentService.currentPrice)"
//        self.lblTimings.text = currentService.
        self.lblDesc.text = currentService.serviceDesc
        if currentService.status == 0 && !fromMyOrder{
            self.lblStatus.text = "Requested"
            self.statusView.isHidden = false
            self.bottomViewHeight.constant = 0
            
        }else if currentService.status == 1 {
            self.lblStatus.text = "Accepted"
            self.statusView.isHidden = false
            self.bottomViewHeight.constant = 0
        }
    }
    func userCheck(){
        if isSP{
            if fromMyOrder{
                self.btnBook.setImage(nil, for: .normal)
                self.btnBook.setTitle("Accept Appointment", for: .normal)
                self.lblDateTitle.text = "Selected Date"
                self.lblTimingTitle.text = "Selected Time"
            }else{
                self.bottomViewHeight.constant = 0
            }
           
            self.statusView.isHidden = true
        }else{
            if fromMyOrder{
                self.statusView.isHidden = false
                self.lblDateTitle.text = "Selected Date"
                self.lblTimingTitle.text = "Selected Time"
                self.bottomViewHeight.constant = 0
            }else{
                self.statusView.isHidden = true
            }
        }
    }
    
    @IBAction func onBook(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "AppointmentVC") as! AppointmentVC
        vcStoreList.shouldDismissInteractivelty = false
        vcStoreList.popupDelegate = self
        vcStoreList.topCornerRadius = 10
        vcStoreList.presentDuration = 0.30
        vcStoreList.dismissDuration = 0.30
        self.present(vcStoreList, animated: true, completion: nil)
    }
    @IBAction func onBack(_ sender: Any) {
        _=navigationController?.popViewController(animated: true)
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
