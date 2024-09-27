//
//  File.swift
//  
//
//  Created by 강현준 on 9/27/24.
//

import Foundation

protocol NSObjectConvertible {
    func toNSObject() -> NSObject
}

extension Int: NSObjectConvertible {
    func toNSObject() -> NSObject {
        return self as NSObject
    }
}

extension Double: NSObjectConvertible {
    func toNSObject() -> NSObject {
        return self as NSObject
    }
}

extension String: NSObjectConvertible {
    func toNSObject() -> NSObject {
        return self as NSObject
    }
}

extension Bool: NSObjectConvertible {
    func toNSObject() -> NSObject {
        return self as NSObject
    }
}
