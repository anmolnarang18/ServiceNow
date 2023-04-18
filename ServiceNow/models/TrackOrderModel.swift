//
//  TrackOrderModel.swift
//  My Trolly
//
//  Created by Bhadresh Sorathiya on 26/04/20.
//  Copyright © 2020 wos_Mitesh. All rights reserved.
//

import Foundation

class TrackOrderModel {
    
    init() {
      
    }
    
    // MARK: Google API Calls for Destination lat long
    static func sendRequestToServer(baseUrl: String, _ url: String, httpMethod: String, isZipped: Bool, receivedResponse:@escaping (_ succeeded: Bool, _ response: [String: Any]) -> Void ) {
        
        let newParam: [String: Any] = [:]
        let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        guard let urlStr = urlString else {
          return
        }
        guard let url = URL(string: (baseUrl) + urlStr) else {
          return
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod as String
        request.timeoutInterval = 20
        
        if httpMethod == "POST" {
           do {
             request.httpBody = try JSONSerialization.data(withJSONObject: newParam, options: [])
           } catch {
           print("Error")
          }
          if isZipped == false {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          } else {
            request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Encoding: gzip")
          }
          request.addValue("application/json", forHTTPHeaderField: "Accept")
        }

        let task = URLSession.shared.dataTask(with: request) {data, response, error in
          if response != nil && data != nil {
            do {
              guard let data = data else {
              return
              }
              if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] {
                receivedResponse(true, json)
              } else {
                receivedResponse(false, [:])
              }
            } catch {
              receivedResponse(false, [:])
            }
          } else {
            receivedResponse(false, [:])
          }
        }
        task.resume()
      }

}


