//
//  ZTLayout.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/3.
//

import UIKit
import SnapKit

enum ZTHVAlignment {
    case h_top
    case h_center
    case h_bottom
    case v_left
    case v_center
    case v_right
    
    case h_last_top
    case h_last_center
    case h_last_bottom
    case v_last_left
    case v_last_center
    case v_last_right
}

class ZTLayout {
    var subViews: [UIView] = []
    var superView: UIView
    var contentItem: ZTItem!
    var contentView: UIView {self.contentItem.itemView}
    init(_ superView: UIView) {
        self.superView = superView
    }
}

extension ZTLayout {
    func setView(_ data: [Any]) {
        for i in 0..<self.subViews.count {
            guard let view = self.subViews[i] as? ZTUITemplate else { return }
            if data.count > i {
                let model = data[i]
                view.setView(model)
            }
        }
    }
}

extension ZTLayout {
    func append(_ item: ZTItem) {
        item.layout = self
        self.contentItem = item
        if superView != contentView {
            superView.addSubview(contentView)
        }
    }
}

// MARK: -
class ZTItem {
    typealias Setting = (ZTItem) -> Void
    weak var layout: ZTLayout!
    
    var superView: UIView!
    var itemView: UIView
    
    var lastItem: ZTItem?
    weak var nextItem: ZTItem?
    
    var superItem: ZTItem?
    var subItems: [ZTItem] = []
    
    var subAlignment: ZTHVAlignment = .h_center
    var subspacing: CGFloat = 0
    
    var alignment: ZTHVAlignment?
    var spacing: CGFloat?
    
    var sizeToFit: Bool = true
    var insertItem: Bool = false
    
    //var autoNewLine: Bool = false
    
    init(_ itemView: UIView = UIView(), setting: Setting? = nil) {
        self.itemView = itemView
        guard let setting = setting else { return }
        setting(self)
    }
}

extension ZTItem {
    func append(_ item: ZTItem) {
        item.alignment = item.alignment ?? superItem?.subAlignment ?? layout.contentItem.alignment
        item.spacing = item.spacing ?? superItem?.subspacing ?? layout.contentItem.spacing
        
        item.superView = self.superView
        item.superItem = self.superItem
        item.layout = self.layout
        item.lastItem = self
        
        self.nextItem = item
        self.layout?.subViews.append(item.itemView)
        
        item.superView.addSubview(item.itemView)
        item.ly()
    }
    
    func insert(_ item: ZTItem) {
        item.alignment = item.alignment ?? self.subAlignment
        item.spacing = item.spacing ?? self.subspacing
        
        item.layout = self.layout
        item.superView = self.itemView
        item.superItem = self
        
        self.subItems.append(item)
        
        item.superView.addSubview(item.itemView)
        item.ly()
    }
    
    func ly() {
        itemView.snp.makeConstraints { make in
            if let lastView = lastItem?.itemView {
                alignment(make, view: lastView)
            }else {
                alignment(make)
            }
            
            if let superItem = superItem, !superItem.sizeToFit {return}
            superSize(make)
        }
    }
    
    func alignment(_ make: ConstraintMaker, view: UIView) {
        let spacing = self.spacing ?? 0
        switch self.alignment! {
        case .h_center:
            make.centerY.equalToSuperview()
            make.left.equalTo(view.snp.right).offset(spacing)
        case .h_top:
            make.top.equalToSuperview()
            make.left.equalTo(view.snp.right).offset(spacing)
        case .h_bottom:
            make.bottom.equalToSuperview()
            make.left.equalTo(view.snp.right).offset(spacing)
        case .v_left:
            make.left.equalToSuperview()
            make.top.equalTo(view.snp.bottom).offset(spacing)
        case .v_center:
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.bottom).offset(spacing)
        case .v_right:
            make.right.equalToSuperview()
            make.top.equalTo(view.snp.bottom).offset(spacing)
            
        case .h_last_center:
            make.centerY.equalTo(view)
            make.left.equalTo(view.snp.right).offset(spacing)
        case .h_last_top:
            make.top.equalTo(view)
            make.left.equalTo(view.snp.right).offset(spacing)
        case .h_last_bottom:
            make.bottom.equalTo(view)
            make.left.equalTo(view.snp.right).offset(spacing)
        case .v_last_left:
            make.left.equalTo(view)
            make.top.equalTo(view.snp.bottom).offset(spacing)
        case .v_last_center:
            make.centerX.equalTo(view)
            make.top.equalTo(view.snp.bottom).offset(spacing)
        case .v_last_right:
            make.right.equalTo(view)
            make.top.equalTo(view.snp.bottom).offset(spacing)
        }
    }
    
    func alignment(_ make: ConstraintMaker) {
        switch self.alignment! {
        case .h_center, .h_last_center:
            make.centerY.left.equalToSuperview()
        case .h_top, .h_last_top:
            make.top.left.equalToSuperview()
        case .h_bottom, .h_last_bottom:
            make.bottom.left.equalToSuperview()
        case .v_left, .v_last_left:
            make.left.top.equalToSuperview()
        case .v_center, .v_last_center:
            make.centerX.top.equalToSuperview()
        case .v_right, .v_last_right:
            make.right.top.equalToSuperview()
        }
    }
    
    func superSize(_ make: ConstraintMaker) {
        switch self.alignment! {
        case .h_center, .h_last_center, .h_top, .h_last_top, .h_bottom, .h_last_bottom:
            make.height.right.lessThanOrEqualToSuperview()
        case .v_left, .v_last_left, .v_center, .v_last_center, .v_right, .v_last_right:
            make.bottom.width.lessThanOrEqualToSuperview()
        }
    }
}
