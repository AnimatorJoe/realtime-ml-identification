//
//  ViewController.swift
//  Realtime-Identification
//
//  Created by Joseph Jin on 10/8/17.
//  Copyright © 2017 AnimatorJoe. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet var guessLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Starting up the camera
        setCameraAccess()
        
    }
    
    // Set up camera access
    func setCameraAccess() {
        // Set up capture session
        let captureSession = AVCaptureSession()
        //captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        // Show camera input to view
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(guessLabel)
        
        
        // Extractiong and analysing image
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        //VNImageRequestHandler(cgImage: <#T##CGImage#>, options: []).perform()
    }
    
    // Called everytime camera updates frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Capturing frame at \(Date())")
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            //print("Result: \(finishedReq.results!)")
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.guessLabel.text = "Guess: " + firstObservation.identifier + "\nConfidence:" + String(firstObservation.confidence * 100) + "%"
            }
            
        }
        
        
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

