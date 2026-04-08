//
//  ProductPurchaseTransactionLog.swift
//  TCPaymentValidation
//
//  Created by Telecloud on 11/01/2024.
//

import Foundation

public struct ProductPurchaseTransactionLog:Codable {

    public var OpenUDID:String?
    public var GUID:String?
    public var BundleName:String?
    public var PlatformTypeId:Int?
    public var Country:String?
    public var IP:String?
    public var AppVersion:String?
    public var PlatformVersion:String?
    public var PlatformDevice:String?
    public var AppLanguageId:Int?
    public var ProductTypeId:Int?
    public var ProductId:String?
    public var ProductPrice:Double?
    public var TransactionStatus:String?
    public var GeoLongitude:Double?
    public var GeoLatitude:Double?
    public var IOSTransactionId:String?
    public var DeviceLanguage:String?
    public var TimeZone:String?
    public var CarrierName:String?
    public var ConnectionType:String?
    public var ProductPurchaseReceiptLogId:Int?
    public var ErrorMessage:String?
    public var IsRooted:Bool?
    public var OrderId:String?

    public init(OpenUDID: String? = nil, GUID: String? = nil, BundleName: String? = nil, PlatformTypeId: Int? = nil, Country: String? = nil, IP: String? = nil, AppVersion: String? = nil, PlatformVersion: String? = nil, PlatformDevice: String? = nil, AppLanguageId: Int? = nil, ProductTypeId: Int? = nil, ProductId: String? = nil, ProductPrice: Double? = nil, TransactionStatus: String? = nil, GeoLongitude: Double? = nil, GeoLatitude: Double? = nil, IOSTransactionId: String? = nil, DeviceLanguage: String? = nil, TimeZone: String? = nil, CarrierName: String? = nil, ConnectionType: String? = nil, ProductPurchaseReceiptLogId: Int? = nil, ErrorMessage: String? = "", IsRooted: Bool? = false, OrderId: String? = "") {
        self.OpenUDID = OpenUDID
        self.GUID = GUID
        self.BundleName = BundleName
        self.PlatformTypeId = PlatformTypeId
        self.Country = Country
        self.IP = IP
        self.AppVersion = AppVersion
        self.PlatformVersion = PlatformVersion
        self.PlatformDevice = PlatformDevice
        self.AppLanguageId = AppLanguageId
        self.ProductTypeId = ProductTypeId
        self.ProductId = ProductId
        self.ProductPrice = ProductPrice
        self.TransactionStatus = TransactionStatus
        self.GeoLongitude = GeoLongitude
        self.GeoLatitude = GeoLatitude
        self.IOSTransactionId = IOSTransactionId
        self.DeviceLanguage = DeviceLanguage
        self.TimeZone = TimeZone
        self.CarrierName = CarrierName
        self.ConnectionType = ConnectionType
        self.ProductPurchaseReceiptLogId = ProductPurchaseReceiptLogId
        self.ErrorMessage = ErrorMessage
        self.IsRooted = IsRooted
        self.OrderId = OrderId
    }
}
