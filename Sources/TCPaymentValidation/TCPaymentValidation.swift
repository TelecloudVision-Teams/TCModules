//
//
//  Created by Admin on 05/07/2022.
//
import ParseCore

@objc public class TCPaymentValidation: NSObject{
    
    static private var loggingCallbackState: ((_ state:TCPaymentValidationTransactionState)->())?
    fileprivate static let shared = TCPaymentValidation()
    static var paymentValidator:PaymentValidator = .parse
    static var urlWCF:String? {
        didSet {
            paymentValidator = .wcf
        }
    }
    static var wcfParam:Data?
    static var installationId:String? = nil
    static var productPurchaseTransactionLog:ProductPurchaseTransactionLog?
    
    fileprivate func validateWCFRequest(completion:@escaping (Result<Double, Error>) -> Void)
    {
        UserSubscribedWCF.checkiOSUserSubscribed(installationId: TCPaymentValidation.installationId) { error, bool in
            if !bool
            {
                let url = URL(string: TCPaymentValidation.urlWCF ?? "")
                guard let requestUrl = url else { fatalError() }
                
                // Prepare URL Request Object
                var request = URLRequest(url: requestUrl)
                request.httpMethod = "POST"
                request.httpBody = TCPaymentValidation.wcfParam
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Perform HTTP Request
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    // Check for Error
                    if let error = error {
                        print("Error took place \(error)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(NSError(domain: "YourApp", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let validateIAPPurchaseresponse = try decoder.decode(ValidateIAPPurchase.self, from: data)
                        if validateIAPPurchaseresponse.hasError
                        {
                            let error = validateIAPPurchaseresponse.error
                            let nserror = NSError(domain: error, code: -1)
                            completion(.failure(WCFValidationError.error(nserror)))
                            return
                        }
                        
                        if validateIAPPurchaseresponse.isSubscribed
                        {
                            let id = validateIAPPurchaseresponse.id
                            TCPaymentValidation.productPurchaseTransactionLog?.ProductPurchaseReceiptLogId = id
                            completion(.success(Double(id)))
                        }
                        else if validateIAPPurchaseresponse.endTransaction
                        {
                            let nserror = WCFValidationError.userUnSubscribedEndTransaction(validateIAPPurchaseresponse.endTransaction)
                            completion(.failure(nserror))
                        }
                    } catch(let error) {
                        let nserror = NSError(domain: "Json Decoder Error", code: -1)
                        completion(.failure(WCFValidationError.error(nserror)))
                    }
                }
                task.resume()
            }else{
                completion(.success(0.0))
            }
        }
    }
    
    static public func validateCreditCardPayment(intentId: String, rechargeType: String, completion:@escaping (Error?) -> Void)
    {
        
        let params = ["rechargeProductType":rechargeType, "paymentIntentId":intentId]
        self.loggingCallbackState?(.CreditCardStartedValidatePayment)
        PFCloud.callFunction(inBackground: "checkPaymentIntent", withParameters: params) { parseObject, error in
            if let error = error
            {
                let newError = self.fetchPaymentSheetError(error: error, intentId: intentId)
                self.loggingCallbackState?(.CreditCardFailedValidatePayment)
                completion(newError)
            }
            else if let parseObject = parseObject as? [String:Any],
                    let checkResponse = PaymentIntentCheckResponse(parseObject: parseObject)
            {
                if checkResponse.error == nil && checkResponse.success {
                    self.loggingCallbackState?(.CreditCardSuccessValidatePayment)
                    completion(nil)
                }
                else
                {
                    let newError = self.fetchPaymentSheetError(error: checkResponse.error, intentId: intentId)
                    self.loggingCallbackState?(.CreditCardFailedValidatePayment)
                    completion(newError)
                }
            }
        }
    }
    //validate purchase
    static private func fetchPaymentSheetError(error:Error?, intentId:String) -> Error
    {
        var text = "Error from stripe payment sheet with intent id: \(intentId)"
        
        var newError:NSError
        if let error = error
        {
            newError = NSError(domain: "\(text) - \(error._domain)", code: error._code, userInfo: error._userInfo as? [String : Any])
        }
        else
        {
            text = "Payment intent is not found - " + text
            newError = NSError(domain: text, code: 0, userInfo: nil)
        }
        return newError
    }
}


