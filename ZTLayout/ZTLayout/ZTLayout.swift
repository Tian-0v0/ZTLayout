//
//  ZTLayout.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/3.
//

import UIKit
import SnapKit
import ZTProject

public enum ZTHVAlignment {
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

public class ZTLayout {
    public var subViews: [UIView] = []
    public var boxViews: [ZTItem] = []
    public var superView: UIView
    public var contentItem: ZTItem!
    public var contentView: UIView {self.contentItem.itemView}
    public init(_ superView: UIView) {
        self.superView = superView
    }
}

public extension ZTLayout {
    func setView(_ data: [Any?]) {
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
            item.superView = superView
            superView.addSubview(contentView)
        }
    }
}

// MARK: -
public class ZTItem {
    public typealias Setting = (ZTItem) -> Void
    public weak var layout: ZTLayout!
    
    public var superView: UIView!
    public var itemView: UIView
    
    public var lastItem: ZTItem?
    weak var nextItem: ZTItem?
    
    public weak var superItem: ZTItem?
    public var subItems: [ZTItem] = []
    
    public var subAlignment: ZTHVAlignment = .h_center
    public var subspacing: CGFloat = 0
    public var contentInset: UIEdgeInsets = .zero
    
    public var alignment: ZTHVAlignment?
    public var spacing: CGFloat?
    
    public var sizeToFit: Bool = true
    public var insertItem: Bool = false
    public var isBox: Bool = false
    
    //var autoNewLine: Bool = false
    
    public init(_ itemView: UIView = UIView(), setting: Setting? = nil) {
        self.itemView = itemView
        guard let setting = setting else { return }
        setting(self)
    }
}

extension ZTItem {
    func append(_ item: ZTItem) {
        if item.insertItem {
            item.superView = self.itemView
            item.superItem = self
            self.subItems.append(item)
        }else {
            item.superView = self.superView
            item.superItem = self.superItem
            item.lastItem = self
        }
        
        item.alignment = item.alignment ?? item.superItem?.subAlignment
        item.spacing = item.spacing ?? item.superItem?.subspacing
        item.layout = self.layout
        
        self.nextItem = item
        if let _ = item.itemView as? ZTUITemplate, !item.isBox {
            self.layout?.subViews.append(item.itemView)
        }
        
        self.layout?.boxViews.append(item)
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
        if let _ = item.itemView as? ZTUITemplate, !item.isBox {
            self.layout?.subViews.append(item.itemView)
        }
        self.layout?.boxViews.append(item)
        
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
