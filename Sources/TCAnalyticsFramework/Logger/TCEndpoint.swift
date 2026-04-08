//
//  TCEndpoint.swift
//  AnalyticsFramework
//
//  Created by Ali on 09/05/2023.
//

import Foundation
struct TCEndpoint
{
    let primaryDNS:String
    let secondaryDNS:String?
    let MPURL:String
    let backendURL:String
    
    var isPrimaryDNS = true
    
    init(primaryDNS:String, secondaryDNS:String?, MPEndpoint: String, backendEndpoint: String) {
        self.primaryDNS = primaryDNS
        self.secondaryDNS = secondaryDNS
        self.MPURL = MPEndpoint
        self.backendURL = backendEndpoint
    }
    
    func backEndFullPath(switchDNS:Bool = false) -> String
    {
        guard let secondaryDNS = secondaryDNS else { return "\(primaryDNS)/\(backendURL)" }
        
        if switchDNS { return "\(secondaryDNS)/\(backendURL)" }
        else { return "\(primaryDNS)/\(backendURL)" }
    }
    func MPFullPath(switchDNS:Bool = false) -> String
    {
        guard let secondaryDNS = secondaryDNS else { return "\(primaryDNS)/\(MPURL)" }
        if switchDNS { return "\(secondaryDNS)/\(MPURL)" }
        else { return "\(primaryDNS)/\(MPURL)" }
    }
}
