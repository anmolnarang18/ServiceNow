//
//  servicesModel.swift
//  ServiceNow
//
//  Created by Anmol Narang on 16/04/23.
//

import Foundation
struct services{
    var serviceName:String! = "Car Service"
    var companyName:String! = "Empire Auto"
    var address:String! = "Kennedy Road"
    var description:String! = "Lorem epsum"
    var price:Double! = 0.0
    var phoneNumber:Double! = 9057830299
    var createdAt:String! = "00-00-0000"
    var userLat:String!
    var userLong:String!
    var status:Int! = 2
    var startTime:String! = ""
    var endTime:String! = ""
    var serviceID:Int!
    var createdBy:String!
    var bookedTime:String!
    var bookedDate:String!
    var orderID:Int!
    var customerName:String!
    var distance:Double!
    var isFavorite:Int! = 0
    
    
    init(){
        
    }

init(fromDictionary dictionary: [String:Any]){
    serviceName = dictionary["serviceName"] as? String
    companyName = dictionary["companyName"] as? String
    address = dictionary["address"] as? String
    description = dictionary["description"] as? String
    price = dictionary["price"] as? Double
    phoneNumber = dictionary["phoneNumber"] as? Double
    createdAt = dictionary["createdAt"] as? String
    userLat = "\(dictionary["userLat"] ?? "")"
    userLong = "\(dictionary["userLong"] ?? "")"
    status = dictionary["status"] as? Int
    startTime = dictionary["startTime"] as? String
    endTime = dictionary["endTime"] as? String
    serviceID = dictionary["serviceID"] as? Int
    createdBy = dictionary["createdBy"] as? String
    bookedTime = dictionary["bookedTime"] as? String
    bookedDate = dictionary["bookedDate"] as? String
    orderID = dictionary["orderID"] as? Int
    customerName = dictionary["customerName"] as? String
}
}
