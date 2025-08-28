//
//  CameraViewController.swift
//  CameraAnimationDemo
//
//  Created by yzf-macmini on 2025/8/28.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - 相机属性
    private let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - UI
    private var placeholderImageView: UIImageView!
    private var captureButton: UIButton!
    private var galleryThumbnail: GalleryThumbnailView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupPlaceholder()
        checkCameraPermission()
        setupUI()
    }
    
    // MARK: - 占位图
    private func setupPlaceholder() {
        placeholderImageView = UIImageView(frame: view.bounds)
        placeholderImageView.contentMode = .scaleAspectFit
        placeholderImageView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        placeholderImageView.image = UIImage(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        placeholderImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(placeholderImageView)
    }
    
    // MARK: - 相机权限
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async { self.setupCamera() }
                } else {
                    print("❌ 用户拒绝了相机权限")
                }
            }
        default:
            print("❌ 没有相机权限")
        }
    }
    
    // MARK: - 相机配置
    private func setupCamera() {
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(input),
              captureSession.canAddOutput(photoOutput) else {
            print("❌ 无法配置摄像头")
            return
        }
        
        captureSession.addInput(input)
        captureSession.addOutput(photoOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        // 后台启动
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.placeholderImageView.isHidden = true
            }
        }
    }
    
    // MARK: - UI 设置
    private func setupUI() {
        // 拍照按钮
        captureButton = UIButton(type: .system)
        captureButton.setTitle("📸", for: .normal)
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        captureButton.tintColor = .white
        captureButton.backgroundColor = UIColor(white: 0.2, alpha: 0.6)
        captureButton.layer.cornerRadius = 40
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // 缩略图按钮，左下角
        galleryThumbnail = GalleryThumbnailView(frame: .zero)
        galleryThumbnail.addTarget(self, action: #selector(openPreview), for: .touchUpInside)
        view.addSubview(galleryThumbnail)
        galleryThumbnail.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            galleryThumbnail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            galleryThumbnail.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            galleryThumbnail.widthAnchor.constraint(equalToConstant: 60),
            galleryThumbnail.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - 拍照
    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - 拍照完成
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        // 屏幕闪光
        CameraAnimationManager.shared.flash(on: view)
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        // 缩略图动画：从缩略图中心放大
        galleryThumbnail.updateThumbnail(with: image)
    }
    
    // MARK: - 点击缩略图进入预览
    @objc private func openPreview() {
        guard let image = galleryThumbnail.thumbImage else { return }
        let previewVC = UIViewController()
        previewVC.view.backgroundColor = .black
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = previewVC.view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewVC.view.addSubview(imageView)
        
        previewVC.modalPresentationStyle = .fullScreen
        present(previewVC, animated: true)
    }
    
    // MARK: - 停止相机会话
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .userInitiated).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
}




