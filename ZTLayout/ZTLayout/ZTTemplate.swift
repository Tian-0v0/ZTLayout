//
//  ZTTemplate.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/3.
//

import UIKit

public protocol ZTUITemplate {
    func appendUI()//添加子组件
    func layoutUI()//布局
    func setting()//风格等设置
    func handler()//事务处理
    func setView(_ data: Any?)//外部输入
}

public extension ZTUITemplate {
    func appendUI(){}
    func layoutUI(){}
    func setting(){}
    func handler(){}
    func setView(_ data: Any?){}
}
