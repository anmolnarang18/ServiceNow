//
//  AppConstants.swift
//  My Trolly
//
//  Created by Bhadresh Sorathiya on 24/04/20.
//  Copyright © 2020 wos_Mitesh. All rights reserved.
//

import SwiftyJSON
import Foundation
import CoreLocation
import GoogleSignIn
import Alamofire
import SVProgressHUD


var isSP = false
var accessToken = UserDefaults.standard.string(forKey: "accessToken")
var userCheckClass : AnyObject!
var userCheckString = String()
//var header : HTTPHeaders = ["access-token":"\(accessToken ?? "")","Content-Type":"application/json","content-language":localLanguage]
//var SHeader : HTTPHeaders = ["Content-Type":"application/json","content-language":localLanguage]
var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() / 60 }

let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
var updatedCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
var DeviceToken = "12345"

var CSmessage = 1
var inStore = false

var userlong = CLLocationDegrees ()
var userlat = CLLocationDegrees()
var arrproductname = [String]()

var currentBranchPhoneNumber = ""
var currentBranchName = ""
var currentAddress = ""
var currentBranchID = 0
var currentdeliveryCharge : Int = 0
var storeCount = Int()
var minimumOrderValue : Int = 0
var MessageingNumber = ""
let appVersionValue = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
let DeviceType = "IOS"
var localLanguage = "en"
let failedResponce = "Something went wrong, please try again later!"
let qtyError = "The number of items of product added to myTrolley cart cannot exceed quantity of the product in stock."
let sessionError = "Login session has expired."
//var appDelegate: AppDelegate {
//    guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
//        fatalError("AppDelegate is not UIApplication.shared.delegate")
//    }
//    return delegate
//


// MARK: -  values
let cameraAlert = "AlertNoCamera"


struct Keys {
    static let facebookSdkScheme = "fb227106948353158"
    //377686923732-92ao7a373ljm45ls8ida5p644k2p6et5.apps.googleusercontent.com
    static let URLSchema = "com.googleusercontent.apps.377686923732-92ao7a373ljm45ls8ida5p644k2p6et5"
    static let googleSDKScheme = "com.googleusercontent.apps.377686923732-92ao7a373ljm45ls8ida5p644k2p6et5"
    static let googleClietId  = "377686923732-92ao7a373ljm45ls8ida5p644k2p6et5.apps.googleusercontent.com"
    static let gmsPlacesClientKey = "AIzaSyBx328yRj2KfH4flcGsAy2Wka8VvbND8u4"
    static let gmsServicesKey = "AIzaSyBx328yRj2KfH4flcGsAy2Wka8VvbND8u4"
    static let googleKey = "AIzaSyBx328yRj2KfH4flcGsAy2Wka8VvbND8u4"
}

struct API {
    static let enterpriceReferenceId = "c0367056fc679a370b5b453128c09f20"
    //static let base_URL = "http://13.245.63.240:3000"
    //static let base_URL = "http://206.189.178.139:8333"
    //static let base_URL  = "http://206.189.178.139:8888"

    static let base_URL = "https://api.my-trolley.com"
    static let GetAppVesion = API.base_URL + "/api/customer/getAppVersion?&deviceType=IOS"
    
    static let Get_customer_search_history = API.base_URL + "/api/customer/getCustomerSearchHistory"
    static let Get_nearby_stores = API.base_URL + "/api/customer/getNearByStores"
    static let get_CategoryDetails = API.base_URL + "/api/customer/getCategoryDetails"
    static let Get_categories = API.base_URL + "/api/customer/getCategoriesForHome"
    static let User_Login = API.base_URL + "/api/customer/login"
    static let User_Register = API.base_URL + "/api/customer/register"
    static let User_Social_login = API.base_URL + "/api/customer/loginViaSocial"
    static let User_ForgotPassword = API.base_URL + "/api/customer/customerForgotPassword"
    static let Check_OTP = API.base_URL + "/api/customer/verifyOTP"
    static let Resend_OTP = API.base_URL + "/api/customer/resendOTP"
    static let Change_Password = API.base_URL + "/api/customer/changePassword"
    static let User_Logout = API.base_URL + "/api/customer/logout"
    static let AddGroceryCart = API.base_URL + "/api/customer/addGroceryCart"
    static let GetOrderBreakDown = API.base_URL + "/api/customer/getOrderBreakDown"
    static let GetPromoCode = API.base_URL + "/api/customer/getPromoCode?branchId="
    static let GetAddressAndSlots = API.base_URL + "/api/customer/getAddressAndSlots"
    static let AddNewAddress = API.base_URL + "/api/customer/addNewAddress"
    static let GetAllAddress = API.base_URL + "/api/customer/getAllAddress"
    static let DeleteAllAddress = API.base_URL + "/api/customer/removeAddress"
    static let UpdateAddress = API.base_URL + "/api/customer/updateAddress"
    static let LoginViaSocial = API.base_URL + "/api/customer/loginViaSocial"
    static let GetMyProfile = API.base_URL + "/api/customer/getMyProfile"
    static let UpdateMyProfile = API.base_URL + "/api/customer/updateProfile"
    static let SearchGroceryItems = API.base_URL + "/api/customer/searchGroceryItems"
    static let SearchProductsList = API.base_URL + "/api/customer/searchProductsList"
    static let CreateGroceryBooking = API.base_URL + "/api/customer/createGroceryBooking"
    static let GetPaymentMethods = API.base_URL + "/api/customer/getPaymentMethods"
    static let GetAllOrders = API.base_URL + "/api/customer/getAllOrders"
    static let giveRating = API.base_URL + "/api/customer/giveRating"
    static let getFoodOrderList = API.base_URL + "/api/customer/getFoodOrderList"
    static let CancelBooking = API.base_URL + "/api/customer/CancelBooking"
    static let GetProductDetails = API.base_URL + "/api/customer/getProductDetails"
    static let GetCatSubCatDetails = API.base_URL + "/api/customer/getCatSubCatDetails"
     static let EditOrderDetail = API.base_URL + "/api/customer/editOrderDetails"
    static let ignoreSubstitution = API.base_URL + "/api/customer/ignoreSubstitutions"
    
    static let GetGroceryList = API.base_URL + "/api/customer/getGroceryList"
    static let GetGroceryListName = API.base_URL + "/api/customer/getGroceryListNames"
    static let DeleteItemOfList = API.base_URL + "/api/customer/addDeleteItemOfList"
    static let CreateGroceryListName = API.base_URL + "/api/customer/createGroceryListName"
    static let DeleteGroceryList = API.base_URL + "/api/customer/deleteList"
    static let UpdateGroceryListName = API.base_URL + "/api/customer/updateGroceryListName"
    static let GetOrderDetails = API.base_URL + "/api/customer/getOrderDetails"
    
    static let GetlistGroceryProducts = API.base_URL + "/api/customer/listProducts"
    
    static let GetPaymentLink = API.base_URL + "/api/customer/getPaymentLink"
    static let GetLinkedProducts = API.base_URL + "/api/customer/getLinkedProducts"
    
    static let GetProductNamesHint = API.base_URL + "/api/customer/getProductNamesHint"
    static let SetDefaultAddress = API.base_URL + "/api/customer/setdefaultAddress"
    
    static let ApplyPromoCode = API.base_URL + "/api/customer/applyPromoCode"
    static let GetCancellationReason = API.base_URL + "/api/customer/getCancellationReasons"
    
    static let GetBrands = API.base_URL + "/api/customer/getTopBrands?branchId="
    static let GetBrandlistProducts = API.base_URL + "/api/customer/listProducts"
    
    static let getFavourities = API.base_URL + "/api/customer/getFavourities"
    static let addFavourities = API.base_URL + "/api/customer/addFavourities"
    static let removeFavourities = API.base_URL + "/api/customer/removeFavourities"
    
    static let getSuperCategories = API.base_URL + "/api/customer/getNearBySuperCategories"
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

enum DeliveryMode: String {
  case bike = "BIKE"
  case truck = "TRUCK"
}

struct infoUrl{
  static let faq = "https://admin.my-trolley.com/#/page/contentFAQs"
  static let tc = "https://admin.my-trolley.com/#/page/contentTermsAndConditions"
  static let pp = "https://admin.my-trolley.com/privacy-policy"
  static let about = "https://admin.my-trolley.com/#/page/contentAboutUs"
}

func roundCorners(view :UIView, corners: UIRectCorner, radius: CGFloat){
    let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    view.layer.mask = mask
}
func showAlertMsg(Message: String, AutoHide:Bool) -> Void
{
    DispatchQueue.main.async
        {
        let alert = UIAlertController(title: "", message: Message, preferredStyle: UIAlertController.Style.alert)
        
        if AutoHide == true
        {
            //alert.dismiss(animated: true, completion:nil)
            
            let deadlineTime = DispatchTime.now() + .seconds(2)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime)
            {
                print("Alert Dismiss")
                alert.dismiss(animated: true, completion:nil)
                
                
            }
        }
        else
        {
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
        }
        UIApplication.shared.windows[0].rootViewController?.present(alert, animated: true, completion: nil)
    }
}
