import SwiftUI
import AVFoundation
import Combine

struct PremiumCameraView: View {
    var onImageCaptured: (UIImage) -> Void
    var onDismiss: () -> Void
    
    @StateObject private var model = CameraModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = model.capturedImage {
                // Preview captured image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    HStack {
                        Button(action: { model.retake() }) {
                            Text("Retake")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Capsule())
                        }
                        Spacer()
                        Button(action: { onImageCaptured(image) }) {
                            Text("Send")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 14)
                                .background(Color.brandPurple)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            } else {
                // Camera Preview
                GeometryReader { geometry in
                    CameraPreview(session: model.session, size: geometry.size)
                        .ignoresSafeArea()
                }
                
                VStack {
                    HStack {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Button(action: { model.toggleFlash() }) {
                            Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 20))
                                .foregroundColor(model.isFlashOn ? .yellow : .white)
                                .padding()
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        // Capture Button
                        Button(action: { model.capturePhoto() }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 70, height: 70)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 58, height: 58)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 40)
                    .overlay(
                        // Flip Camera
                        Button(action: { model.flipCamera() }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 40)
                        , alignment: .bottomTrailing
                    )
                }
            }
        }
        .onAppear {
            model.checkPermissionsAndStart()
        }
        .onDisappear {
            model.stopSession()
        }
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var capturedImage: UIImage?
    @Published var isFlashOn = false
    
    private let output = AVCapturePhotoOutput()
    private var currentPosition: AVCaptureDevice.Position = .back
    
    func checkPermissionsAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            break
        }
    }
    
    func setupCamera() {
        do {
            session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        if output.supportedFlashModes.contains(.on) || output.supportedFlashModes.contains(.auto) {
            settings.flashMode = isFlashOn ? .on : .off
        }
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            
            // Fix orientation
            let fixedImage = fixOrientation(img: image)
            
            DispatchQueue.main.async {
                self.capturedImage = fixedImage
                self.session.stopRunning()
            }
        }
    }
    
    private func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        img.draw(in: CGRect(origin: .zero, size: img.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func flipCamera() {
        session.beginConfiguration()
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        session.removeInput(currentInput)
        
        currentPosition = currentPosition == .back ? .front : .back
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        session.commitConfiguration()
    }
    
    func retake() {
        capturedImage = nil
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    var session: AVCaptureSession
    var size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: size))
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = CGRect(origin: .zero, size: size)
        }
    }
}
