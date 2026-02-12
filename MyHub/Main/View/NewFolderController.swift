//
//  NewFolderController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class NewFolderController: UIViewController {
    lazy var contentV: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .regular, size: 16)
        label.textColor = UIColor.rgbHex("#8C8C8C")
        label.text = "Add a folder"
        return label
    }()
    
    lazy var numL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .regular, size: 12)
        label.textColor = UIColor.rgbHex("#CDCDCD")
        label.text = "0/50"
        return label
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
    
    lazy var sureBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Confirm", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#14171C", 0.5), for: .normal)
        btn.backgroundColor = UIColor.rgbHex("#DDF75B", 0.5)
        btn.titleLabel?.font = UIFont.GoogleSans(size: 12)
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    lazy var inputV: UITextView = {
        let view = UITextView()
        view.textColor = UIColor.rgbHex("#14171C")
        view.font = UIFont.GoogleSans(weight: .medium, size: 14)
        view.contentInset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.rgbHex("#EDEDED").cgColor
        return view
    }()
    let maxCharacterCount: Int = 50
    var isKeyShow: Bool = false
    
    var parentId: String = ""
    
    var fileId: String = ""
    
    var isFixName: Bool = false
    
    var newSuccessBlock: (() -> Void)?
    
    var fixSuccessBlock: ((_ name: String) -> Void)?
    
    init(parentId: String) {
        self.parentId = parentId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        self.view.addSubview(self.contentV)
        self.view.addSubview(self.closeBtn)
        self.contentV.addSubview(self.nameL)
        self.contentV.addSubview(self.numL)
        self.contentV.addSubview(self.sureBtn)
        self.contentV.addSubview(self.inputV)
        
        self.contentV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.contentV.snp.top)
            make.size.equalTo(CGSize(width: 52, height: 52))
        }
        
        self.nameL.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(14)
        }
        
        self.numL.snp.makeConstraints { make in
            make.top.equalTo(self.nameL.snp.bottom).offset(6)
            make.left.equalTo(14)
        }
        self.sureBtn.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.right.equalTo(-14)
            make.size.equalTo(CGSize(width: 72, height: 28))
        }
        
        self.inputV.snp.makeConstraints { make in
            make.top.equalTo(self.numL.snp.bottom).offset(20)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(80)
            make.bottom.equalTo(-20)
            
        }
        self.inputV.delegate = self
        self.inputV.becomeFirstResponder()
        self.sureBtn.addTarget(self, action: #selector(clickSureAction), for: .touchUpInside)
        self.closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
        self.keyboardInfo()
    }
    
    func keyboardInfo() {
        if self.isFixName {
            self.nameL.text = "Rename"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrame), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHid), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardFrame(_ info: Notification) {
        guard let frame = info.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let y = frame.height - view.safeAreaInsets.bottom + 14
        self.contentV.snp.updateConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(self.isKeyShow ? -y : 0)
        }
    }
    
    @objc func keyboardShow() {
        self.isKeyShow = true
    }
    @objc func keyboardHid() {
        self.isKeyShow = false
    }
    
    @objc func clickCloseAction() {
        self.dismiss(animated: false)
    }
    @objc func clickSureAction() {
        if let t = self.inputV.text, t.count > 0 {
            self.createRequest(t)
        }
    }
    
    func createRequest(_ text: String) {
        if self.isFixName {
            HttpManager.share.reNameFileApi(fileId: self.fileId, fileName: text) { [weak self] status, errMsg in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if status == .success {
                        self.fixSuccessBlock?(text)
                        self.dismiss(animated: false)
                    } else {
                        ToastTool.instance.show("Please try again", .fail)
                    }
                }
            }
        } else {
            HttpManager.share.createFolderApi(parentId: self.parentId, fileName: text) { [weak self] status, errMsg in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if status == .success {
                        self.newSuccessBlock?()
                        self.dismiss(animated: false)
                    } else {
                        ToastTool.instance.show("Failed to add folder!", .fail)
                    }
                }
            }
        }
    }
}

extension NewFolderController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 限制输入字数
        if textView.text.count > maxCharacterCount {
            textView.text = String(textView.text.prefix(maxCharacterCount))
        }
        // 更新字数统计
        updateCountLabel()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 计算替换后的文本长度
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // 允许删除操作，或者新文本不超过最大长度
        return updatedText.count <= maxCharacterCount || text.isEmpty
    }
    
    private func updateCountLabel() {
        let currentCount = self.inputV.text.count
        self.numL.text = "\(currentCount)/\(maxCharacterCount)"
      
        if currentCount >= maxCharacterCount {
            self.numL.textColor = UIColor.rgbHex("#FF7A34")
        } else {
            self.numL.textColor = UIColor.rgbHex("#CDCDCD")
        }
        self.sureBtn.setTitleColor(UIColor.rgbHex("#14171C", currentCount > 0 ? 1 : 0.5), for: .normal)
        self.sureBtn.backgroundColor = UIColor.rgbHex("#DDF75B", currentCount > 0 ? 1 : 0.5)
    }
}
