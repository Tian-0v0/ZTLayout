//
//  UIView+ZT.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/3.
//

import UIKit
import SnapKit
import ZTProject

public extension UIView {
    private struct AssociatedKeys {
        static var zt_width = "zt_width"
        static var zt_height = "zt_height"
        static var zt_frameChange = "zt_frameChange"
        
        static var zt_width_scale = "zt_width_scale"
        static var zt_width_offset = "zt_width_offset"
        static var zt_height_scale = "zt_height_scale"
        static var zt_height_offset = "zt_height_offset"
        
        static var zt_size_didset = "zt_size_didset"
        
        static var ty_disposeBag = "ty_disposeBag"
    }
    
    var zt_width: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_width) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_width, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var zt_height: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_height) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_height, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var zt_frameChange: ((CGRect)->Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_frameChange) as? (CGRect)->Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_frameChange, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var zt_width_scale: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_width_scale) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_width_scale, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var zt_width_offset: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_width_offset) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_width_offset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var zt_height_scale: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_height_scale) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_height_scale, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var zt_height_offset: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_height_offset) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_height_offset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var zt_size_didset: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_size_didset) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_size_didset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var ty_disposeBag: DisposeBag {
        get {
            if let disposeBag = objc_getAssociatedObject(self, &AssociatedKeys.ty_disposeBag) as? DisposeBag {
                return disposeBag
            }
            self.ty_disposeBag = DisposeBag()
            return self.ty_disposeBag
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ty_disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIView: ZTAwakeProtocol {
    public static var selectors: [Selector] {
        return [#selector(didMoveToSuperview), #selector(layoutSubviews)]
    }
    @objc func wr_didMoveToSuperview() {
        self.wr_didMoveToSuperview()
        
        
        if let _ = self.superview, self.zt_width > 0 {
            self.snp.makeConstraints { make in
                make.width.equalTo(zt_width)
            }
        }
        if let _ = self.superview, self.zt_height > 0 {
            self.snp.makeConstraints { make in
                make.height.equalTo(zt_height)
            }
        }
        if let _ = self.superview, self.zt_width_scale > 0 {
            self.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(zt_width_scale).offset(zt_width_offset)
            }
        }
        if let _ = self.superview, self.zt_height_scale > 0 {
            self.snp.makeConstraints { make in
                make.height.equalToSuperview().multipliedBy(zt_height_scale).offset(zt_height_offset)
            }
        }
    }
    
    @objc func wr_layoutSubviews() {
        self.wr_layoutSubviews()
        if let zt_frameChange = zt_frameChange {
            zt_frameChange(self.frame)
        }
    }
}
