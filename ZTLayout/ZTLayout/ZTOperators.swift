//
//  ZTOperators.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/3.
//

import Foundation

precedencegroup FormPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator +++ : FormPrecedence

public func +++ (left: ZTLayout, right: ZTItem) -> ZTItem {
    right.insertItem = true
    right.isBox = true
    left.append(right)
    return right
}

public func +++ (left: ZTItem, right: ZTItem) -> ZTItem {
    right.insertItem = true
    right.isBox = true
    left.append(right)
    return right
}

infix operator >>> : FormPrecedence

@discardableResult
public func >>> (left: ZTItem, right: ZTItem) -> ZTItem {
    if left.insertItem {
        left.insert(right)
    }else {
        left.append(right)
    }
    return right
}

infix operator --- : FormPrecedence

public func --- (left: ZTItem, right: Int = 1) -> ZTItem {
    var count = 0
    var item = left
    while count < right {
        guard let superItem = item.superItem else { return item }
        item = superItem
        count += 1
    }
    item.insertItem = false
    return item
}
