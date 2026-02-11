//
//  OpenPhotoController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class OpenPhotoController: SuperController {
    lazy var imageV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private var model: VideoData = VideoData()
    
    init(model: VideoData) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        self.navbar.nameL.text = self.model.name
        self.view.addSubview(self.imageV)
        self.imageV.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.navbar.snp.bottom)
        }
        self.imageV.setImage(self.model.thumbnail, placeholder: "")
    }
}
