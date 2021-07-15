//
//  ZTLayoutDemoViewController.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/14.
//

import UIKit
import ZTProject
import IQKeyboardManagerSwift

extension String {
    func cgFloat() -> CGFloat {
        return CGFloat(Float(self) ?? 0)
    }
}

extension Optional where Wrapped == String {
    func cgFloat() -> CGFloat {
        return CGFloat(Float(self ?? "") ?? 0)
    }
}

extension UIImage {
    class func color(_ color: UIColor, size: CGSize = .init(width: 10, height: 10)) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
    
func View(_ color: UIColor = .lightGray) -> UIView {
    let v = UIView()
    v.backgroundColor = color
    return v
}
func Button(_ title: String) -> UIButton {
    let bt = UIButton()
    bt.setTitle(title, for: .normal)
    bt.setTitleColor(.white, for: .normal)
    bt.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    bt.border(size: 1, color: UIColor.lightGray, mask: .all)
    return bt
}
func Switch(_ title: String) -> UIButton {
    let bt = UIButton()
    bt.setTitle(title, for: .normal)
    bt.setTitleColor(.white, for: .normal)
    bt.setBackgroundImage(.color(.blue), for: .normal)
    bt.setBackgroundImage(.color(.red), for: .selected)
    bt.border(size: 1, color: UIColor.lightGray, mask: .all)
    return bt
}
func Label(_ title: String) -> UILabel {
    let l = UILabel()
    l.text = title
    return l
}
func TextField(_ value: CGFloat) -> UITextField {
    let tf = UITextField()
    tf.text = "\(value)"
    tf.keyboardType = .numbersAndPunctuation
    tf.layer.borderWidth = 1
    tf.layer.borderColor = UIColor.black.cgColor
    tf.textAlignment = .center
    tf.zt_width = 60
    tf.zt_height = 30
    tf.delegate = tf
    return tf
}
func TextField(_ value: Int) -> UITextField {
    return TextField(CGFloat(value))
}

class ZTLayoutSetConfigBaseView: UIView {
    var config: LyItemConfig
    var alignment: ZTHVAlignment?
    var value: CGFloat?
    var values: [CGFloat]?
    var counts: [Int]?
    var title: String?
    var zt_superview: UIView
    
    var updateAction = PublishRelay<Void?>()
    
    init(superview: UIView, config: LyItemConfig, title: String? = nil, alignment: ZTHVAlignment? = nil, value: CGFloat? = nil, values: [CGFloat]? = nil, counts: [Int]? = nil) {
        self.config = config
        self.alignment = alignment
        self.value = value
        self.values = values
        self.counts = counts
        self.title = title
        self.zt_superview = superview
        super.init(frame: .zero)
        
        self.setting()
        self.layoutUI()
        self.handler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setting() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
    func layoutUI() {}
    func handler() {}
}

class ZTLayoutSetGroupView: ZTLayoutSetConfigBaseView {
    lazy var add = Button("+")
    lazy var remove = Button("-")
    lazy var groupSpacingView = TextField(10)
    lazy var groupCountViewArr = [UITextField]()
    lazy var groupSpacingViewArr = [UITextField]()
    
    var groupCountBgItem: LyItem!
    var groupSpacingBgItem: LyItem!
    
    // 追加？
    override func layoutUI() {
        let config01 = LyItemConfig()
        config01.subAlignment = .v_left
        config01.subSpacing = 5
        config01.subExtendSuper = true
        
        let config02 = LyItemConfig()
        config02.subAlignment = .h_center
        config02.subSpacing = 5
        
        let config03 = LyItemConfig()
        config03.subAlignment = .h_center
        config03.subSpacing = 5
        config03.subExtendSuper = true
        
        groupCountBgItem = .init(view: UIView(), config: config03)
        groupSpacingBgItem = .init(view: UIView(), config: config03)
        
        LyItem(view: self, superView: self.zt_superview, config: config01) {[weak self] ly in
            ly._subItem.append(LyItem(view: Label("多行设置")))
            ly._subItem.append(LyItem(view: UIView(), config: config02) { ly in
                ly._subItem.append(LyItem(view: Label("添加组")))
                ly._subItem.append(LyItem(view: self!.add))
                ly._subItem.append(LYBorderItem(view: self!.remove))
            })
            ly._subItem.append(LyItem(view: UIView(), config: config02) { ly in
                ly._subItem.append(LyItem(view: Label("组间距")))
                ly._subItem.append(LYBorderItem(view: self!.groupSpacingView))
            })
            ly._subItem.append(LyItem(view: Label("每行显示个数")))
            ly._subItem.append(self!.groupCountBgItem)
            ly._subItem.append(LyItem(view: Label("子视图间距")))
            ly._subItem.append(self!.groupSpacingBgItem)
        }.layout()
    }
    
    override func handler() {
        add.rx.tap.bind{[weak self] _ in
            self?.addGroup()
            self?.updateAction.accept(nil)
        }.disposed(by: zt_disposeBag)
            
        remove.rx.tap.bind{[weak self] _ in
            self?.removeGroup()
            self?.updateAction.accept(nil)
        }.disposed(by: zt_disposeBag)
        
        groupSpacingView.rx.text.map{$0.cgFloat()}.bind {[weak self] rs in
            self?.config.subGroupSpacingEqual = rs
            self?.updateAction.accept(nil)
        }.disposed(by: zt_disposeBag)
    }
    
    func addGroup() {
        let tf1 = TextField(1)
        let tf2 = TextField(5)
        self.groupCountViewArr.append(tf1)
        self.groupSpacingViewArr.append(tf2)
        self.groupCountBgItem._view.subviews.forEach{$0.removeFromSuperview()}
        self.groupSpacingBgItem._view.subviews.forEach{$0.removeFromSuperview()}
        
        groupCountBgItem._subItem.append(LyItem(view: tf1))
        groupSpacingBgItem._subItem.append(LyItem(view: tf2))
        
        groupCountBgItem.addSubView()
        groupSpacingBgItem.addSubView()
        
        groupCountBgItem.layout()
        groupSpacingBgItem.layout()
        
        tf1.rx.controlEvent(.editingDidEnd).bind{[weak self] _ in self?.updateConfig()}.disposed(by: zt_disposeBag)
        tf2.rx.controlEvent(.editingDidEnd).bind{[weak self] _ in self?.updateConfig()}.disposed(by: zt_disposeBag)
        
        self.updateConfig()
        self.settingTF()
    }
    func settingTF() {
        for tf in groupSpacingViewArr {
            if tf == groupSpacingViewArr.last {
                tf.returnKeyType = .done
            }else {
                tf.returnKeyType = .next
            }
        }
        for tf in groupCountViewArr {
            if tf == groupCountViewArr.last {
                tf.returnKeyType = .done
            }else {
                tf.returnKeyType = .next
            }
        }
    }
    func removeGroup() {
        if groupCountViewArr.count <= 0 {return}
        self.groupCountViewArr.removeLast().removeFromSuperview()
        self.groupSpacingViewArr.removeLast().removeFromSuperview()
        
        groupCountBgItem._subItem.removeLast()
        groupSpacingBgItem._subItem.removeLast()
        
        self.updateConfig()
        self.settingTF()
    }
    func updateConfig() {
        var countArr = [Int]()
        var spacingArr = [CGFloat]()
        for i in 0..<groupCountViewArr.count {
            let count = Int(groupCountViewArr[i].text ?? "0") ?? 1
            let spacing = groupSpacingViewArr[i].text?.cgFloat() ?? 0
            countArr.append(count)
            spacingArr.append(spacing)
        }
        
        self.config.subGroupSpacing = spacingArr
        self.config.subLineMaxCount = countArr
        
        self.updateAction.accept(nil)
    }
}

class ZTLayoutSetAliView: ZTLayoutSetConfigBaseView {
    lazy var titleLabel = Label("子视图对齐方式")
    lazy var view = View()
    lazy var switchArr = [UIButton]()
    lazy var ItemArr = [LyItem]()
    
    override func layoutUI() {
        
        let titleArr = ["h_top","h_center","h_bottom","v_left","v_center","v_right"]//,"h_last_top","h_last_center","h_last_bottom","v_last_left","v_last_center","v_last_right"]
        for title in titleArr {
            let bt = Switch(title)
            let item = LyItem(view: bt)
            switchArr.append(bt)
            ItemArr.append(item)
        }
        let config01 = LyItemConfig()
        config01.subAlignment = .v_left
        config01.subSpacing = 5
        
        let config02 = LyItemConfig()
        config02.subAlignment = .h_bottom
        config02.subSpacing = 5
        config02.subLineMaxCount = [3,3]
        config02.subGroupSpacingEqual = 2
        
        LyItem(view: self, superView: self.zt_superview, config: config01) {[weak self] ly in
            ly._subItem.append(LyItem(view: self!.titleLabel))
            ly._subItem.append(LYBorderItem(view: UIView(), config: config02) { ly in
                ly._subItem = self!.ItemArr
            })
        }.layout()
    }
    
    override func handler() {
        switchArr.forEach{ bt in
            bt.rx.tap.map{[weak bt] _ in bt!}.bind {[weak self] bt in
                for v in self!.switchArr {
                    v.isSelected = v == bt
                    if v.isSelected {
                        self?.setConfig(v.titleLabel?.text)
                    }
                }
            }.disposed(by: self.zt_disposeBag)
        }
    }
    
    func setConfig(_ title: String?) {
        let ali: ZTHVAlignment
        switch title {
        case "h_top": ali = .h_top
        case "h_center": ali = .h_center
        case "h_bottom": ali = .h_bottom
        case "v_left": ali = .v_left
        case "v_center": ali = .v_center
        case "v_right": ali = .v_right
        case "h_last_top": ali = .h_last_top
        case "h_last_center": ali = .h_last_center
        case "h_last_bottom": ali = .h_last_bottom
        case "v_last_left": ali = .v_last_left
        case "v_last_center": ali = .v_last_center
        case "v_last_right": ali = .v_last_right
        default: ali = .h_center
        }
        self.config.subAlignment = ali
        
        self.updateAction.accept(nil)
    }
}

class ZTLayoutDemoViewController01: UIViewController {
    lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .lightGray
        return contentView
    }()
    
    lazy var config = LyItemConfig()
    lazy var aliView = ZTLayoutSetAliView(superview: self.view, config: config)
    lazy var grpView = ZTLayoutSetGroupView(superview: self.view, config: config)
    lazy var showItem: LyItem = {
        let v = UIView()
        v.layer.borderColor = UIColor.black.cgColor
        v.layer.borderWidth = 1
        config.subSpacing = 10
        return LYBorderItem(view: v, config: config)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        let config01 = LyItemConfig()
        config01.subAlignment = .v_left
        config01.subSpacing = 5
        
        LyItem(view: contentView, superView: self.view, config: config01) {[weak self] ly in
            ly._subItem.append(LyItem(view: self!.aliView))
            ly._subItem.append(LyItem(view: self!.grpView))
            ly._subItem.append(self!.showItem)
        }.layout()
        
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.left.equalToSuperview()
        }
        
        hanlder()
    }
    
    let disposeBag = DisposeBag()
    func hanlder() {
        aliView.updateAction.bind(to: updateBinder).disposed(by: disposeBag)
        grpView.updateAction.bind(to: updateBinder).disposed(by: disposeBag)
    }
    
    var updateBinder: Binder<Void?> {
        return Binder(self) { ws, _ in
            guard let subLineMaxCount = ws.config.subLineMaxCount, subLineMaxCount.count > 0 else {return}
            ws.showItem._subItem.forEach{$0._view.removeFromSuperview()}
            ws.showItem._subItem.removeAll()
            for section in subLineMaxCount {
                for _ in 0..<section {
                    let view = UIView()
                    view.backgroundColor = .red
                    view.zt_width = CGFloat(arc4random_uniform(50)+20)
                    view.zt_height = CGFloat(arc4random_uniform(30)+20)
                    ws.showItem._subItem.append(LyItem(view: view))
                }
            }
            ws.showItem.reload()
        }
    }
}

extension UITextField: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType != .done {
            IQKeyboardManager.shared.goNext()
        }
        textField.resignFirstResponder()
        return true
    }
}
