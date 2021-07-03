//
//  UIView+ZT.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/3.
//

import UIKit
import SnapKit

extension UIView {
    private struct AssociatedKeys {
        static var zt_width = "zt_width"
        static var zt_height = "zt_height"
        static var zt_frameChange = "zt_frameChange"
        static var zt_frame = "zt_frame"
    }
    
    var zt_width: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_width) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_width, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    var zt_height: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zt_height) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zt_height, newValue, .OBJC_ASSOCIATION_ASSIGN)
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
}

extension UIView: ZTAwakeProtocol {
    public static var selectors: [Selector] {
        return [#selector(willMove(toSuperview:)), #selector(layoutSubviews)]
    }
    @objc func wr_willMove(toSuperview newSuperview: UIView?) {
        if let width = self.zt_width {
            self.snp.makeConstraints { make in
                make.width.greaterThanOrEqualTo(width)
            }
        }
        if let height = self.zt_height {
            self.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(height)
            }
        }
    }
    
    @objc func wr_layoutSubviews() {
        self.wr_layoutSubviews()
        guard let zt_frameChange = zt_frameChange else { return }
        zt_frameChange(self.frame)
    }
}
