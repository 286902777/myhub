//
//  SortController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class SortController: UIViewController {
    let tCellIdentifier: String = "SortTypeCellIdentifier"
    let oCellIdentifier: String = "SortOrderCellIdentifier"
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.layer.cornerRadius = 20
        table.bounces = false
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        table.register(SortTypeCell.self, forCellReuseIdentifier: tCellIdentifier)
        table.register(SortOrderCell.self, forCellReuseIdentifier: oCellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()

    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
    
    var listArr: [SortListData] = []
    var clickBlock: ((_ type: HUB_SortType, _ asc: Bool) -> Void)?
    var currentType: HUB_SortType = .upload
    var currentAsc: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        view.addSubview(self.tableView)
        view.addSubview(self.closeBtn)
        self.tableView.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(394)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.tableView.snp.top)
            make.size.equalTo(CGSize(width: 52, height: 52))
        }
        self.closeBtn.addTarget(self, action: #selector(clickCancelAction), for: .touchUpInside)
        setData()
    }
    
    @objc func clickCancelAction() {
        self.dismiss(animated: false)
    }
    
    func setData() {
        self.listArr.removeAll()
        var typeList: [SortData] = []
        typeList.append(self.setModel(type: .upload, name: "By upload time", select: self.currentType == .upload))
        typeList.append(self.setModel(type: .size, name: "By file size", select: self.currentType == .size))
        typeList.append(self.setModel(type: .type, name: "By file type", select: self.currentType == .type))
        let typeData: SortListData = SortListData()
        typeData.name = "Sort"
        typeData.isType = true
        typeData.list = typeList
        var orderList: [SortData] = []
        orderList.append(self.setOrderModel(name: "Ascending", select: self.currentAsc, asc: true))
        orderList.append(self.setOrderModel(name: "Descending", select: !self.currentAsc, asc: false))
        let orderData: SortListData = SortListData()
        orderData.name = "Order"
        orderData.list = orderList
        self.listArr.append(typeData)
        self.listArr.append(orderData)
        self.tableView.reloadData()
    }
    
    func setModel(type: HUB_SortType, name: String, select: Bool) -> SortData {
        let model = SortData()
        model.type = type
        model.name = name
        model.select = select
        return model
    }
    
    func setOrderModel(name: String, select: Bool, asc: Bool) -> SortData {
        let model = SortData()
        model.name = name
        model.select = select
        model.ascending = asc
        return model
    }
}

extension SortController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SortTypeCell = tableView.dequeueReusableCell(withIdentifier: tCellIdentifier) as! SortTypeCell
        let oCell: SortOrderCell = tableView.dequeueReusableCell(withIdentifier: oCellIdentifier) as! SortOrderCell
        if let m = self.listArr.safeIndex(indexPath.section) {
            if let data = m.list.safeIndex(indexPath.row) {
                if m.isType {
                    cell.initData(data)
                    return cell
                } else {
                    oCell.initData(data)
                    return oCell
                }
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.listArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let m = self.listArr.safeIndex(section) {
            return m.list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = self.listArr.safeIndex(indexPath.section) {
            if let data = m.list.safeIndex(indexPath.row) {
                if m.isType {
                    self.currentType = data.type
                } else {
                    self.currentAsc = data.ascending
                }
                self.setData()
            }
            self.clickBlock?(self.currentType, self.currentAsc)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 28, height: 40))
        view.backgroundColor = .white
        let label = UILabel()
        label.font = UIFont.GoogleSans(size: 16)
        label.textColor = UIColor.rgbHex("#8C8C8C")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
        }
        if let m = self.listArr.safeIndex(section) {
            label.text = m.name
        }
        return view
    }
}
