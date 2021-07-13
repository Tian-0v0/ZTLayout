//
//  ZTAwakeManager.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/13.
//

import UIKit

public class ZTAwakeManager {
    public static func install() {
        UIViewController.awake()
        UIView.awake()
    }
}
