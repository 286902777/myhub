//
//  HUBRateView.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class HUBRateView: UIView {
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.bounces = false
        table.register(HUBRateCell.self, forCellReuseIdentifier: cellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
        
    let cellIdentifier: String = "RateCellIdentifier"
    var listArr: [RateData] = []

    var clickBlock: ((_ state: HUB_RateState) -> Void)?
    
    class func view() -> HUBRateView {
        let view = HUBRateView()
        view.initUI()
        return view
    }
    
    func initUI() {
        self.isHidden = true
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        self.addEffectView(CGSize(width: 80, height: 192))
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(4)
            make.right.equalTo(-4)
        }
    }
    
    func setData(_ state: HUB_RateState) {
        listArr.removeAll()
        listArr.append(self.addItem(HUB_RateState.two, HUB_RateState.two == state))
        listArr.append(self.addItem(HUB_RateState.oneBan, HUB_RateState.oneBan == state))
        listArr.append(self.addItem(HUB_RateState.oneTwo, HUB_RateState.oneTwo == state))
        listArr.append(self.addItem(HUB_RateState.one, HUB_RateState.one == state))
        listArr.append(self.addItem(HUB_RateState.sevenFive, HUB_RateState.sevenFive == state))
        listArr.append(self.addItem(HUB_RateState.ban, HUB_RateState.ban == state))
        self.isHidden = false
        self.tableView.reloadData()
    }
    
    func addItem(_ state: HUB_RateState, _ select: Bool) -> RateData{
        let model = RateData()
        model.name = state
        model.select = select
        return model
    }
    
    func dismiss() {
        guard self.isHidden == false else { return }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.25) { [weak self] in
            guard let self = self else { return }
            self.isHidden = true
        }
    }
}

extension HUBRateView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HUBRateCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! HUBRateCell
        if let data = self.listArr.safeIndex(indexPath.row) {
            cell.initData(data)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.listArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _ = self.listArr.map({$0.select = false})
        if let model = self.listArr.safeIndex(indexPath.row) {
            model.select = true
            self.clickBlock?(model.name)
        }
        tableView.reloadData()
        self.dismiss()
    }
}

class RateData: SuperData {
    var name: HUB_RateState = .one
    var select: Bool = false
}
