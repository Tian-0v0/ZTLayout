//
//  ZTAwakeProtocol.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/3.
//

import UIKit

public protocol ZTAwakeProtocol: AnyObject {
    static var selectors: [Selector] {get}
    static func awake(_ selectors: [Selector])
    static func awake()
}

public extension ZTAwakeProtocol {
    static func awake(_ selectors: [Selector]) {
        for selector in selectors {
            let str = ("wr_" + selector.description).replacingOccurrences(of: "__", with: "_")
            if let originalMethod = class_getInstanceMethod(self, selector),
                let swizzledMethod = class_getInstanceMethod(self, Selector(str)) {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    static func awake() {
        self.awake(self.selectors)
    }
}

public class ZTAwakeManager {
    public static func install() {
        UIView.awake()
    }
}

