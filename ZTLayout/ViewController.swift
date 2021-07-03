//
//  ViewController.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/3.
//

import UIKit

class ViewController: UIViewController {

    var itemView: UILabel {
        let view1 = UILabel()
        view1.backgroundColor = .red
        view1.zt_width = CGFloat(arc4random_uniform(50)+20)
        view1.zt_height = CGFloat(arc4random_uniform(50)+20)
        return view1
    }
    
    lazy var ly = ZTLayout(self.view)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ZTAwakeManager.install()
        
        self.ly
//            +++ ZTItem(UIView()) { ly in
//                ly.subAlignment = .v_center
//                ly.subspacing = 10
//                ly.itemView.backgroundColor = .lightGray
//            }
            +++ ZTItem(self.view) { ly in
                ly.subAlignment = .v_center
                ly.subspacing = 10
                ly.itemView.backgroundColor = .lightGray
                ly.sizeToFit = false
            }
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
            +++ ZTItem(UIView()){ ly in
                ly.subspacing = 5
                ly.subAlignment = .h_center
                
                ly.itemView.backgroundColor = .blue
            }
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
            +++ ZTItem(UIView()){ ly in
                ly.subspacing = 5
                ly.subAlignment = .v_center
                
                ly.itemView.backgroundColor = .yellow
            }
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
        --- 1
            >>> ZTItem(itemView)
            >>> ZTItem(itemView)
        
//        self.ly.contentView.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
    }


}

