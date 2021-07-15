//
//  ViewController.swift
//  ZTLayout
//
//  Created by zhangtian on 2021/7/3.
//

import UIKit
import ZTProject

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    lazy var tableview: UITableView = {
        let tb = UITableView(frame: .zero, style: .insetGrouped)
        tb.rowHeight = 55
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ZTAwakeManager.install()
        
        self.view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let m1 = ZTDemoCellModel(title: "多行布局", vc: ZTLayoutDemoViewController01())
        let data = Observable.of([m1])
        
        data.bind(to: self.tableview.rx.items) { tb, ip, item in
            let cell = tb.dequeueReusableCell(withIdentifier: "cell")!
            cell.selectionStyle = .none
            cell.textLabel?.text = item.title
            return cell
        }.disposed(by: disposeBag)
        
        self.tableview.rx.modelSelected(ZTDemoCellModel.self).bind {[weak self] rs in
            self?.navigationController?.pushViewController(rs.vc, animated: true)
        }.disposed(by: disposeBag)
    }
}

class ZTDemoCellModel {
    var title: String
    var vc: UIViewController
    init(title: String, vc: UIViewController) {
        self.title = title
        self.vc = vc
    }
}

