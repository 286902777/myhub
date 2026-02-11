//
//  FullScreenController.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class FullScreenController: UIViewController {
    private(set) lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.isUserInteractionEnabled = true
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        view.insetsLayoutMarginsFromSafeArea = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .zero
        view.spacing = 0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI() {
        view.backgroundColor = .black
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension FullScreenController {
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

