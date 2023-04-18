//
//  AppointmentVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit

class AppointmentVC: BottomPopupViewController {
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?

    @IBOutlet weak var phoneNumerTxt: UITextField!
    @IBOutlet weak var serviceDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceDatePicker.minimumDate = Date()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBook(_ sender: Any) {
    
    }
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override var popupTopCornerRadius: CGFloat { return topCornerRadius ?? CGFloat(10) }
    
    override var popupPresentDuration: Double { return presentDuration ?? 1.0 }
    
    override var popupDismissDuration: Double { return dismissDuration ?? 1.0 }
    
    override var popupShouldDismissInteractivelty: Bool { return shouldDismissInteractivelty ?? true }

}
