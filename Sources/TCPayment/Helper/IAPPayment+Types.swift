
//
// TCPayment+Types.swift
// TCPayment
//
// Copyright (c) 2015 Andrea Bizzotto (bizz84@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import StoreKit
import TCSharedFramework

/// Result for Validation Param TypeID
@objc public enum ProductTypeID: Int {
    case free
    case consumable
    case nonconsumable
    case autorenewable
    case nonrenewable
    
    public var id:Int
    {
        switch self {
        case .free:
            return 0
        case .consumable:
            return 1
        case .nonconsumable:
            return 2
        case .autorenewable:
            return 3
        case .nonrenewable:
            return 4
        }
    }
    
    public var description:String
    {
        switch self {
        case .free:
            return "free"
        case .consumable,
             .nonconsumable:
            return "productId"
        case .autorenewable,
             .nonrenewable:
            return "subscriptionId"
        }
    }
    
    public init(id:Int) {
        switch id {
        case 0:
            self = .free
        case 1:
            self = .consumable
        case 2:
            self = .nonconsumable
        case 3:
            self = .autorenewable
        case 4:
            self = .nonrenewable
            
        default:
            self = .consumable
        }
    }
}




