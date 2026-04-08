//
//  UserSubscribed.swift
//  TCPaymentValidation
//
//  Created by Telecloud on 18/01/2024.
//
import Foundation

public class UserSubscribedWCF {
        
    fileprivate func checkiOSUserSubscribed(installationId:String?,completionHandler:@escaping(Error?,Bool)->Void) {
        if let installationId = installationId
        {
            let url = URL(string: "http://service.mobilepasse.com/GetArticles.svc/json/CheckiOSUserSubscribedv2")
            guard let requestUrl = url else { fatalError() }
            // Prepare URL Request Object
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            let body = "\"\(installationId)\""
            request.httpBody = body.data(using: .utf8)
            request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
            // Perform HTTP Request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    completionHandler(error,false)
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "No data", code: 0)
                    completionHandler(error,false)
                    return
                }
                
                if let value = String(data: data, encoding: .utf8){
                    if let boolValue = Bool(value.lowercased()) {
                        print("Boolean Value: \(boolValue)")
                        completionHandler(nil,boolValue)
                    } else {
                        let error = NSError(domain: "Parsing error", code: 0)
                        completionHandler(error,false)
                    }
                }
            }
            task.resume()
        }else{
            let error = NSError(domain: "No installation Id", code: 0)
            completionHandler(error,false)
        }
    }
}

extension UserSubscribedWCF{
    
    fileprivate static let shared = UserSubscribedWCF()
    
    public class func checkiOSUserSubscribed(installationId:String?,completionHandler:@escaping(Error?,Bool)->Void)
    {
        return shared.checkiOSUserSubscribed(installationId: installationId,completionHandler: completionHandler)
    }
}
