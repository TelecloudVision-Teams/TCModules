import Foundation
import TCNetwork
import TCSharedFramework
import TCLocationFramework

struct AnalyticsTransactionLog: Codable {
    let authToken: String?
    let epoch: Int64?
    let openUDID: String?
    let GUID: String?
    let bundleName: String?
    let platformTypeId: Int?
    let country: String?
    let IP: String?
    let appVersion: String?
    let platformVersion: String?
    let platformDevice: String?
    let appLanguageId: Int?
    let productTypeId: Int?
    let productId: String?
    let productPrice: Double
    let transactionStatus: String?
    let geoLongitude: Double
    let geoLatitude: Double
    let iOSTransactionId: String?
    let deviceLanguage: String?
    let timeZone: String?
    let carrierName: String?
    let connectionType: String?
    let timeFormat: String?
    let productPurchaseReceiptLogId: Int?
    let errorMessage: String?
    let isRooted: Bool?
    let orderId: String?
    let parseUserId: String?
    let storefront: String
    let storefrontId: String
    let storefrontPrice: Double
    let storefrontCurrency: String
    let notificationType: String
    let isSandbox: Bool?
    
    init(deviceInfo: DeviceInfo,
         productId: String?,
         transactionId: String?,
         orderId: String?,
         cost: Double,
         productTypeId: Int,
         language: TCLanguage,
         transactionStatus: String,
         userId: String?,
         error: Error?,
         storeInfo: SKStoreInfo?)
    {
        let token = TCNetwork.shared.token
        self.authToken = token?.token
        self.epoch = token?.epoch
        self.openUDID = deviceInfo.openUDID
        self.GUID = deviceInfo.guid
        self.bundleName = Bundle.main.bundleIdentifier
        self.platformTypeId = deviceInfo.platformTypeID
        self.country = TCLocationManager.shared.isoCode
        self.IP = ""
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.platformVersion = deviceInfo.platformVersion
        self.platformDevice = deviceInfo.deviceType
        self.appLanguageId = language.rawValue
        self.productTypeId = productTypeId
        self.productId = productId
        self.productPrice = cost
        self.transactionStatus = transactionStatus
        self.geoLongitude = TCLocationManager.shared.longitude
        self.geoLatitude = TCLocationManager.shared.latitude
        self.iOSTransactionId = transactionId
        self.deviceLanguage = deviceInfo.language
        self.timeZone = deviceInfo.timeZone
        self.carrierName = deviceInfo.carrierName
        self.connectionType = deviceInfo.connectionType
        self.timeFormat = deviceInfo.timeFormat
        self.productPurchaseReceiptLogId = 0
        self.errorMessage = error?.localizedDescription ?? ""
        self.isRooted = deviceInfo.isJailbroken
        self.orderId = orderId
        self.parseUserId = userId
        self.storefront = storeInfo?.storefront ?? ""
        self.storefrontId = storeInfo?.storefrontId ?? ""
        self.storefrontPrice = storeInfo?.storefrontPrice ?? 0
        self.storefrontCurrency = storeInfo?.storefrontCurrency ?? ""
        self.notificationType = storeInfo?.notificationType ?? ""
        self.isSandbox = TCAnalytics.configuration.environment == .sandbox
    }
    func toDictionary() -> [String: Any]? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("AnalyticsTransactionLog → Failed to convert to dictionary: \(error)")
            return nil
        }
    }
}
