//
//  UploadController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit
import Photos

enum HUB_UplodType: Int { ///INIT/PASSED/REJECTED
    case photo = 0
    case file
    case folder
}

class UploadController: UIViewController {
    
    var isNewFolder: Bool = false
    
    private let contentV: UIView = UIView()

    private let closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()

    var folderBlock: (() -> Void)?
    var uploadBlock: (() -> Void)?
   
    private var parent_id: String = ""
    
    init(parent_id: String = "", folder: Bool = false) {
        self.parent_id = parent_id
        self.isNewFolder = folder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup() {
        self.view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        self.view.addSubview(self.contentV)
        self.view.addSubview(self.closeBtn)
        self.closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
        self.contentV.layer.cornerRadius = 20
        self.contentV.layer.masksToBounds = true
        self.contentV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(self.isNewFolder ? 300 : 200)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.contentV.snp.top)
            make.size.equalTo(CGSize(width: 52, height: 52))
        }
        let photoView: UIView = self.createView(.photo, 0)
        let fileView: UIView = self.createView(.file, 1)
        let folderView: UIView = self.createView(.folder, 2)
        self.contentV.addSubview(photoView)
        self.contentV.addSubview(fileView)
        if isNewFolder {
            self.contentV.addSubview(folderView)
        }
        photoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        fileView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(100)
        }
        if isNewFolder {
            folderView.snp.makeConstraints { make in
                make.left.bottom.right.equalToSuperview()
                make.top.equalTo(200)
            }
        }
    }
    
    func createView(_ type: HUB_UplodType, _ tag: Int) -> UIView {
        let v = UIView()
        let label: UILabel = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .medium, size: 18)
        v.addSubview(label)
        let subLabel: UILabel = UILabel()
        subLabel.textColor = UIColor.rgbHex("#14171C", 0.5)
        subLabel.font = UIFont.GoogleSans(weight: .regular, size: 12)
        v.addSubview(subLabel)
        let subV = UIView()
        subV.layer.cornerRadius = 10
        v.addSubview(subV)
        label.snp.makeConstraints { make in
            make.top.left.equalTo(28)
        }
        subLabel.snp.makeConstraints { make in
            make.left.equalTo(28)
            make.top.equalTo(label.snp.bottom).offset(16)
        }
        subV.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        v.tag = tag
        v.layer.cornerRadius = 20
        switch type {
        case .photo:
            label.text = "Video"
            subLabel.text = "Import from system album"
            subV.backgroundColor = UIColor.rgbHex("#DDF75B", 0.5)
            v.backgroundColor = UIColor.rgbHex("#FDFFF2")
        case .file:
            label.text = "File"
            subLabel.text = "Import from system file"
            subV.backgroundColor = UIColor.rgbHex("#FF7A34", 0.5)
            v.backgroundColor = UIColor.rgbHex("#FFF5F0")
        case .folder:
            label.text = "New Folder"
            subLabel.text = "Add a new folder"
            subV.backgroundColor = UIColor.rgbHex("#8041FF", 0.5)
            v.backgroundColor = UIColor.rgbHex("#F5F0FF")
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickAction(_:)))
        v.addGestureRecognizer(tap)
        return v
    }
    
    @objc func clickAction(_ tap: UITapGestureRecognizer) {
        switch tap.view?.tag {
        case 0:
            getPhotoAuth()
        case 1:
            openFileAction()
        default:
            self.folderBlock?()
            self.dismiss(animated: false)
        }
    }
    
    @objc func clickCloseAction() {
        self.dismiss(animated: false)
    }
}

extension UploadController {
    func getPhotoAuth() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.openPhotoPage()
                    }
                }
            })
        case .limited, .authorized:
            self.openPhotoPage()
        default:
            break
//            ESToast.instance.show("Enable photo access permissions in Settings > Privacy > Photos to upload videos.", ToastImage.none)
        }
    }
    
    func openFileAction() {
        let vc = UIDocumentPickerViewController(forOpeningContentTypes: [.movie, .video, .image])
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func openPhotoPage() {
        let vc = UIImagePickerController()
        vc.allowsEditing = false
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.mediaTypes = [UTType.movie.identifier, UTType.image.identifier]
        self.present(vc, animated: true, completion: nil)
    }
    
    // 处理选定的文件
    func getPickedFile(_ url: URL, completion: @escaping ((_ model: VideoData?, _ resultUrl: URL?) -> Void)) {
        let exp = url.pathExtension
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil, nil)
            return
        }
        
        let authozied = url.startAccessingSecurityScopedResource()
        if authozied {
            //通过文件协调器读取文件地址
            let fileCoordinator = NSFileCoordinator()
            fileCoordinator.coordinate(readingItemAt: url, options: [.withoutChanges], error: nil) { _ in
                let fileExtension = url.pathExtension.lowercased()
                let videoExtensions = ["mp4", "mov", "avi", "mkv", "flv", "m4v"]
                if videoExtensions.contains(fileExtension) {
                    HubTool.share.getVideoImage(videoURL: url) { image in
                        DispatchQueue.main.async {
                            let newName: String = "\(Int(Date().timeIntervalSince1970) * 1000).\(exp)"
                            let destinationURL = documentsDirectory.appendingPathComponent(newName)
                            do {
                                try FileManager.default.copyItem(at: url, to: destinationURL)
                                let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                                let model = VideoData()
                                if let fileSize = attributes[.size] as? UInt64 {
                                    model.file_size = Double(fileSize)
                                    model.parent_id = self.parent_id
                                    model.size = Double(fileSize).computeFileSize()
                                    model.movieAddress = destinationURL.lastPathComponent
                                    model.name = destinationURL.lastPathComponent
                                    model.ext = destinationURL.pathExtension
                                    model.image = image
                                    model.date = Double(Date().timeIntervalSince1970 * 1000)
                                }
                                url.stopAccessingSecurityScopedResource()
                                completion(model, destinationURL)
                            } catch {
                                url.stopAccessingSecurityScopedResource()
                                completion(nil, nil)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let newName: String = "\(Int(Date().timeIntervalSince1970) * 1000).\(exp)"
                        let destinationURL = documentsDirectory.appendingPathComponent(newName)
                        do {
                            try FileManager.default.copyItem(at: url, to: destinationURL)
                            let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                            let model = VideoData()
                            if let fileSize = attributes[.size] as? UInt64 {
                                model.file_size = Double(fileSize)
                                model.parent_id = self.parent_id
                                model.size = Double(fileSize).computeFileSize()
                                model.movieAddress = destinationURL.lastPathComponent
                                model.name = destinationURL.lastPathComponent
                                model.ext = destinationURL.pathExtension
                                if let img = UIImage(contentsOfFile: destinationURL.path), let data = img.compressSize(with: 1024 * 2), let image = UIImage(data: data) {
                                    model.image = image
                                }
                                model.date = Double(Date().timeIntervalSince1970 * 1000)
                            }
                            url.stopAccessingSecurityScopedResource()
                            completion(model, destinationURL)
                        } catch {
                            url.stopAccessingSecurityScopedResource()
                            completion(nil, nil)
                        }
                    }
                }
            }
        }
    }
}
// MARK: - Photo delegate
extension UploadController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let model = VideoData()
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            HubTool.share.getVideoImage(videoURL: videoURL) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let destinationURL = documentsDirectory.appendingPathComponent(videoURL.lastPathComponent)
                    do {
                        try FileManager.default.copyItem(at: videoURL, to: destinationURL)
                        let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                        if let fileSize = attributes[.size] as? UInt64 {
                            model.file_size = Double(fileSize)
                            model.size = Double(fileSize).computeFileSize()
                            model.movieAddress = destinationURL.lastPathComponent
                            model.name = destinationURL.lastPathComponent
                            model.ext = destinationURL.pathExtension
                            model.image = image
                            model.parent_id = self.parent_id
                            model.date = Double(Date().timeIntervalSince1970 * 1000)
//                            FileUploadDownTool.instance.upload(model)
//                            self.dismiss(animated: false) {
//                                self.uploadClosePage()
//                            }
                        }
                    } catch {}
                }
            }
        }
        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            let destinationURL = documentsDirectory.appendingPathComponent(imageURL.lastPathComponent)
            do {
                try FileManager.default.copyItem(at: imageURL, to: destinationURL)
                let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                if let fileSize = attributes[.size] as? UInt64 {
                    if let originalImage = info[.originalImage] as? UIImage, let data = originalImage.compressSize(with: 1024 * 2) {
                        model.image = UIImage(data: data)
                    }
                    model.file_size = Double(fileSize)
                    model.parent_id = self.parent_id
                    model.size = Double(fileSize).computeFileSize()
                    model.movieAddress = destinationURL.lastPathComponent
                    model.name = destinationURL.lastPathComponent
                    model.ext = destinationURL.pathExtension
                    model.date = Double(Date().timeIntervalSince1970 * 1000)
//                    FileUploadDownTool.instance.upload(model)
//                    self.dismiss(animated: false) { [weak self] in
//                        guard let self = self else { return }
//                        DispatchQueue.main.async {
//                            self.uploadClosePage()
//                        }
//                    }
                }
            } catch {}
        }
    }
}
extension UploadController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // 用户选择了文件，你可以处理这些文件的URL
        guard let fileUrl = urls.first else { return }
        // 当完成处理后，关闭文件选择器
        controller.dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            self.getPickedFile(fileUrl) { model, url in
                if let m = model {
//                    FileUploadDownTool.instance.upload(m)
//                    self.dismiss(animated: false) { [weak self] in
//                        guard let self = self else { return }
//                        DispatchQueue.main.async {
//                            self.uploadClosePage()
//                        }
//                    }
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // 用户取消了选择
        controller.dismiss(animated: true, completion: nil)
    }
}
