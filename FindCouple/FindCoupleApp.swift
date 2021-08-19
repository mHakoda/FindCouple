//
//  FindCoupleApp.swift
//  FindCouple
//
//  Created by mr. Hakoda on 13.08.2021.
//

import SwiftUI

@main
struct FindCoupleApp: App {
    @ObservedObject var model = Model()
    
    init() {
        RequestIP()
    }
    var body: some Scene {
        WindowGroup {
            if model.gameBehavior.geo == "UA" {
                ContentView().environmentObject(model)
            } else if model.gameBehavior.geo == "RU"  {
                Text("Test")
            }
            
        }
    }
    
    
    
    func RequestIP() {
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            print("Bad URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data,
                       let response = response as? HTTPURLResponse,
                       error == nil else {                                              // check for fundamental networking error
                       print("error", error ?? "Unknown error")
                       return
                   }

                   guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                       print("statusCode should be 2xx, but is \(response.statusCode)")
                        //print("response = \(response)")
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                            if let responseJSON = responseJSON as? [String: Any] {
                                print(responseJSON)
                                _ = responseJSON["detail"] as! String
                            }
                       return
                   }

                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            
                if let responseJSON = responseJSON as? [String: Any] {
                    let ip = responseJSON["ip"] as? String ?? ""
                    
                    RequestGeo(ip: ip)
                }
            }
        }.resume()
    }
    
    func RequestGeo(ip: String) {
        guard let url = URL(string: "https://ipinfo.io/\(ip)?token=e66dcefb79c94b") else {
            print("Bad URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data,
                       let response = response as? HTTPURLResponse,
                       error == nil else {                                              // check for fundamental networking error
                       print("error", error ?? "Unknown error")
                       return
                   }

                   guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                       print("statusCode should be 2xx, but is \(response.statusCode)")
                        //print("response = \(response)")
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                            if let responseJSON = responseJSON as? [String: Any] {
                                print(responseJSON)
                                _ = responseJSON["detail"] as! String
                            }
                       return
                   }

                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let responseJSON = responseJSON as? [String: Any] {
                    let country = responseJSON["country"] as? String ?? ""
                    model.gameBehavior.geo = country
                }
            }
        }.resume()
    }
}
