//
//  File.swift
//  
//
//  Created by 강현준 on 9/27/24.
//

import Foundation

public protocol NSObjectConvertible {
    func toNSObject() -> NSObject
}

extension Int: NSObjectConvertible {
    public func toNSObject() -> NSObject {
        return self as NSObject
    }
}

extension Double: NSObjectConvertible {
    public func toNSObject() -> NSObject {
        return self as NSObject
    }
}

extension String: NSObjectConvertible {
    public func toNSObject() -> NSObject {
        return self as NSObject
    }
}

extension Bool: NSObjectConvertible {
    public func toNSObject() -> NSObject {
        return self as NSObject
    }
}
