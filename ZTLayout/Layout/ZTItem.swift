//
//  ZTItem.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/13.
//

import UIKit
import SnapKit

extension LyItem {
    var subItem: [LyItem] {self._subItem}
}

public class LyItemConfig {
    var alignment: ZTHVAlignment?
    var spacing: CGFloat?
    var extendSuper: Bool?
    
    
    var subAlignment: ZTHVAlignment = .h_center
    var subSpacing: CGFloat = 0
    var subExtendSuper: Bool = false
    
    var tag: Int = 0
    var row: Int = 0
    var section: Int = 0
    
    var height: CGFloat?
    var heightScale: CGFloat?
    var heightOffset: CGFloat?
    
    var width: CGFloat?
    var widthScale: CGFloat?
    var widthOffset: CGFloat?
    
    var subHeight: [CGFloat]?
    var subHeightScale: [CGFloat]?
    var subHeightOffset: [CGFloat]?
    
    var subHeightEqual: CGFloat?
    var subHeightScaleEqual: CGFloat?
    var subHeightOffsetEqual: CGFloat?
    
    var subWidth: [CGFloat]?
    var subWidthScale: [CGFloat]?
    var subWidthOffset: [CGFloat]?
    
    var subWidthEqual: CGFloat?
    var subWidthScaleEqual: CGFloat?
    var subWidthOffsetEqual: CGFloat?
    
    
    // 确定行列数进行布局
    var subLineMaxCount: [Int]?
    var subGroupSpacing: [CGFloat]?
    var subGroupSpacingEqual: CGFloat = 10
    
    func updateConfig(_ config: LyItemConfig) {
        self.alignment = alignment ?? config.subAlignment
        self.spacing = spacing ?? config.subSpacing
        self.extendSuper = extendSuper ?? config.subExtendSuper
        
        self.height = height ?? config.subHeightEqual ?? config.subHeight?[self.tag]
        self.heightScale = heightScale ?? config.subHeightScaleEqual ?? config.subHeightScale?[self.tag]
        self.heightOffset = heightOffset ?? config.subHeightOffsetEqual ?? config.subHeightOffset?[self.tag]
        
        self.width = width ?? config.subWidthEqual ?? config.subWidth?[self.tag]
        self.widthScale = widthScale ?? config.subWidthScaleEqual ?? config.subWidthScale?[self.tag]
        self.widthOffset = widthOffset ?? config.subWidthOffsetEqual ?? config.subWidthOffset?[self.tag]
    }
}

public class LYBorderItem: LyItem {
    override init(view: UIView, superView: UIView? = nil, config: LyItemConfig = .init(), subItem: SubItemLayout? = nil) {
        config.extendSuper = true
        super.init(view: view, superView: superView, config: config, subItem: subItem)
    }
}

public class LyItem {
    var _view: UIView
    var _superView: UIView?
    var _lastView: UIView?
    
    var _subItem: [LyItem] = []
    var _config: LyItemConfig
    
    typealias SubItemLayout = (LyItem) -> Void
    init(view: UIView, superView: UIView? = nil, config: LyItemConfig = .init(), subItem: SubItemLayout? = nil) {
        self._view = view
        self._superView = superView
        self._config = config
        
        guard let subItem = subItem else { return }
        subItem(self)
        
        self.addSuperView()
        self.addSubView()
    }
    
    func reload() {
        self.addSubView()
        self.layout()
    }
    
    func addSuperView() {
        _superView?.addSubview(_view)
    }
    func addSubView() {
        for i in 0..<_subItem.count {
            let item = _subItem[i]
            item._config.updateConfig(_config)
            item._config.tag = i
            _view.addSubview(item._view)
        }
    }
    
    func layout() {
        var lastView: UIView? = nil
        for item in self._subItem {
            if let rows = _config.subLineMaxCount {
                self.multiLineLayout(rows, view: item._view, config: item._config)
            }else {
                item._lastView = lastView
                self.layout(view: item._view, last: lastView, config: item._config)
            }
            lastView = item._view
        }
        
        _subItem.forEach{$0.layout()}
    }
    func layout(view: UIView, last: UIView?, config: LyItemConfig) {
        view.snp.makeConstraints { make in
            if let last = last {
                self.alignment(make, last: last, spacing: config.spacing!, alignment: config.alignment!)
            }else {
                self.alignment(make, alignment: config.alignment!)
            }
            if config.extendSuper! {
                self.superSize(make, alignment: config.alignment!)
            }
        }
    }
    func multiLineLayout(_ rows: [Int], view: UIView, config: LyItemConfig) {
        var _last: UIView? = nil
        var _tops: [UIView]? = nil
        var _sections: [[UIView]] = .init()
        
        var last: UIView? = nil
        var tops: [UIView]? = nil
        var sum: Int = 0
        
        var row: Int = 0
        var sectioin: Int = 0
        
        for i in rows {
            var views = [UIView]()
            for j in sum..<sum+i  {
                if j == config.tag {
                    config.row = row
                    config.section = sectioin
                    _last = last
                    _tops = .init(tops ?? [])
                }
                last = _subItem[j]._view //子View数 小于 行列数
                views.append(last!)
                row += 1
            }
            _sections.append(views)
            tops = views
            last = nil
            sum += i
            sectioin += 1
            row = 0
        }
        
        self.multiLineLayout(view: view, config: config, last: _last, tops: _tops, sections: _sections)
    }
    func multiLineLayout(view: UIView, config: LyItemConfig, last: UIView?, tops: [UIView]?, sections: [[UIView]]) {
        var isBottom: Bool = false
        var isRight: Bool = false
        var isTop: Bool = false
        
        for views in sections {
            for v in views {
                if view == v {
                    isRight = view == views.last
                    isBottom = views == sections.last
                    isTop = views == sections.first
                }
            }
        }
        
        view.snp.makeConstraints { make in
            let groupSpacing = _config.subGroupSpacing?[config.section] ?? _config.subGroupSpacingEqual
            if let last = last {
                self.alignment(make, last: last, tops: tops, spacing: config.spacing!, groupSpacing: groupSpacing, alignment: config.alignment!)
            }else {
                self.alignment(make, tops: tops, groupSpacing: groupSpacing, alignment: config.alignment!)
            }
            // size
            if isBottom {
                switch config.alignment! {
                case .h_center, .h_last_center, .h_top, .h_last_top, .h_bottom, .h_last_bottom:
                    make.bottom.lessThanOrEqualToSuperview()
                case .v_left, .v_last_left, .v_center, .v_last_center, .v_right, .v_last_right:
                    make.right.lessThanOrEqualToSuperview()
                }
            }
            if isRight {
                switch config.alignment! {
                case .h_center, .h_last_center, .h_top, .h_last_top, .h_bottom, .h_last_bottom:
                    make.right.lessThanOrEqualToSuperview()
                case .v_left, .v_last_left, .v_center, .v_last_center, .v_right, .v_last_right:
                    make.bottom.lessThanOrEqualToSuperview()
                }
            }
            if isTop {
                switch config.alignment! {
                case .h_center, .h_last_center, .h_top, .h_last_top, .h_bottom, .h_last_bottom:
                    make.top.greaterThanOrEqualToSuperview()
                case .v_left, .v_last_left, .v_center, .v_last_center, .v_right, .v_last_right:
                    make.left.greaterThanOrEqualToSuperview()
                }
            }
        }
    }
}

extension LyItem {
    func alignment(_ make: ConstraintMaker, tops: [UIView]?, groupSpacing: CGFloat, alignment: ZTHVAlignment) {
        switch alignment {
        case .h_last_center, .h_center, .h_last_top, .h_top, .h_last_bottom, .h_bottom:
            make.left.equalToSuperview()
            if let tops = tops {
                for top in tops {
                    make.top.greaterThanOrEqualTo(top.snp.bottom).offset(groupSpacing)
                }
            }else {
                make.top.greaterThanOrEqualToSuperview()
            }
        case .v_last_left, .v_left, .v_last_center, .v_center, .v_last_right, .v_right:
            make.top.equalToSuperview()
            if let tops = tops {
                for top in tops {
                    make.left.greaterThanOrEqualTo(top.snp.right).offset(groupSpacing)
                }
            }else {
                make.left.greaterThanOrEqualToSuperview()
            }
        }
    }
    func alignment(_ make: ConstraintMaker, last: UIView, tops: [UIView]?, spacing: CGFloat, groupSpacing: CGFloat, alignment: ZTHVAlignment) {
        switch alignment {
        case .h_last_center, .h_center:
            make.centerY.equalTo(last)
            make.left.equalTo(last.snp.right).offset(spacing)
        case .h_last_top, .h_top:
            make.top.equalTo(last)
            make.left.equalTo(last.snp.right).offset(spacing)
        case .h_last_bottom, .h_bottom:
            make.bottom.equalTo(last)
            make.left.equalTo(last.snp.right).offset(spacing)
        case .v_last_left, .v_left:
            make.left.equalTo(last)
            make.top.equalTo(last.snp.bottom).offset(spacing)
        case .v_last_center, .v_center:
            make.centerX.equalTo(last)
            make.top.equalTo(last.snp.bottom).offset(spacing)
        case .v_last_right, .v_right:
            make.right.equalTo(last)
            make.top.equalTo(last.snp.bottom).offset(spacing)
        }
        
        switch alignment {
        case .h_last_center, .h_center, .h_last_top, .h_top, .h_last_bottom, .h_bottom:
            if let tops = tops {
                for top in tops {
                    make.top.greaterThanOrEqualTo(top.snp.bottom).offset(groupSpacing)
                }
            }else {
                make.top.greaterThanOrEqualToSuperview()
            }
        case .v_last_left, .v_left, .v_last_center, .v_center, .v_last_right, .v_right:
            if let tops = tops {
                for top in tops {
                    make.left.greaterThanOrEqualTo(top.snp.right).offset(groupSpacing)
                }
            }else {
                make.left.greaterThanOrEqualToSuperview()
            }
        }
    }
    
    func alignment(_ make: ConstraintMaker, last: UIView, spacing: CGFloat, alignment: ZTHVAlignment) {
        switch alignment {
        case .h_center:
            make.centerY.equalToSuperview()
            make.left.equalTo(last.snp.right).offset(spacing)
        case .h_top:
            make.top.equalToSuperview()
            make.left.equalTo(last.snp.right).offset(spacing)
        case .h_bottom:
            make.bottom.equalToSuperview()
            make.left.equalTo(last.snp.right).offset(spacing)
        case .v_left:
            make.left.equalToSuperview()
            make.top.equalTo(last.snp.bottom).offset(spacing)
        case .v_center:
            make.centerX.equalToSuperview()
            make.top.equalTo(last.snp.bottom).offset(spacing)
        case .v_right:
            make.right.equalToSuperview()
            make.top.equalTo(last.snp.bottom).offset(spacing)
            
        case .h_last_center:
            make.centerY.equalTo(last)
            make.left.equalTo(last.snp.right).offset(spacing)
        case .h_last_top:
            make.top.equalTo(last)
            make.left.equalTo(last.snp.right).offset(spacing)
        case .h_last_bottom:
            make.bottom.equalTo(last)
            make.left.equalTo(last.snp.right).offset(spacing)
        case .v_last_left:
            make.left.equalTo(last)
            make.top.equalTo(last.snp.bottom).offset(spacing)
        case .v_last_center:
            make.centerX.equalTo(last)
            make.top.equalTo(last.snp.bottom).offset(spacing)
        case .v_last_right:
            make.right.equalTo(last)
            make.top.equalTo(last.snp.bottom).offset(spacing)
        }
    }
    
    func alignment(_ make: ConstraintMaker, alignment: ZTHVAlignment) {
        switch alignment {
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
    
    func superSize(_ make: ConstraintMaker, alignment: ZTHVAlignment) {
        switch alignment {
        case .h_center, .h_last_center, .h_top, .h_last_top, .h_bottom, .h_last_bottom:
            make.height.right.lessThanOrEqualToSuperview()
        case .v_left, .v_last_left, .v_center, .v_last_center, .v_right, .v_last_right:
            make.bottom.width.lessThanOrEqualToSuperview()
        }
    }
}
