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

func +++ (left: ZTLayout, right: ZTItem) -> ZTItem {
    left.append(right)
    right.insertItem = true
    return right
}

func +++ (left: ZTItem, right: ZTItem) -> ZTItem {
    left.append(right)
    right.insertItem = true
    return right
}

infix operator >>> : FormPrecedence

@discardableResult
func >>> (left: ZTItem, right: ZTItem) -> ZTItem {
    if left.insertItem {
        left.insert(right)
    }else {
        left.append(right)
    }
    return right
}

infix operator --- : FormPrecedence

func --- (left: ZTItem, right: Int = 1) -> ZTItem {
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
