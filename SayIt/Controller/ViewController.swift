//
//  ViewController.swift
//  SayIt
//
//  Created by Ahmed AlOtaibi on 11/25/17.
//  Copyright © 2017 Ahmed AlOtaibi. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

    // MARK: - Flash state
enum FlashState {
    case off
    case on
}

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var photoData: Data?
    
    var flashControlState: FlashState = .off
    
    var speechSynthseizer = AVSpeechSynthesizer()
    
    
    @IBOutlet weak var camView: UIView!
    @IBOutlet weak var upperLabel: RoundedShadowView!
    @IBOutlet weak var captureView: RoundedShadowImage!
    @IBOutlet weak var flashButton: RoundedShadowButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        speechSynthseizer.delegate = self
        spinner.isHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = camView.bounds  //To set the previewLayer as the main view (cam).

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCamView))
        tap.numberOfTapsRequired = 1 // add a tap gesture to the app
        
        captureSession = AVCaptureSession() //Create a AV AVCaptureSession object.
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080      //to capture the iPhone screen.
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)       // try to capture from the camera
            if  captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()       //get the output from the camera
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect // Keep the aspect ratio
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait // always portrait
                
                camView.layer.addSublayer(previewLayer!) //add previewLayer to the main view (camView)
                camView.addGestureRecognizer(tap) //
                captureSession.startRunning()  // Start the session
            }
        } catch {
            debugPrint(error) // catch errors and desplay them.
        }
    }
    
    @objc func didTapCamView() {
        self.camView.isUserInteractionEnabled = false // Disable taking multiple pictures
        self.upperLabel.isHidden = false
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        
        
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat // preview sized photos for lighter use
        
        if flashControlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // Mark:-
    // MARK: - Image Classification
    func resultsMethod(request: VNRequest, error: Error?) {
        // analyzing the data
        guard let result = request.results as? [VNClassificationObservation] else { return }
        for classification in result {
            if classification.confidence < 0.7 {   // don't show result < 70%
                let unknownObjMessage = "I'm not sure what this is"
                self.idLabel.text = unknownObjMessage
                self.confidenceLabel.text = ""
                
                synthesizeSpeech(fromString: unknownObjMessage)
                break
            } else {
                let identification = classification.identifier
                let confidence = Int(classification.confidence * 100)
                let knownObjMessage = "I'm \(confidence) percent sure it's \(identification)"
                
                self.idLabel.text =  identification //Assign the idLabel to "what is it"
                self.confidenceLabel.text = String(confidence) // confidence
                
                synthesizeSpeech(fromString: knownObjMessage)
                break
            }
        }
    }
    
    // Passing a string to the AVSpeechUtterance and Say it
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthseizer.speak(speechUtterance)
    }
    
    // MARK: - Flash Toggle @IBAction
    @IBAction func flashBtnWasPressed(_ sender: Any) {
        switch flashControlState {
        case .off:
            flashButton.setTitle("Flash: ON", for: .normal)
            flashControlState = .on
        case .on:
            flashButton.setTitle("Flash: OFF", for: .normal)
            flashControlState = .off


        }
    }
    
}

    // MARK: - Implementing ML Model
extension ViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation() // returns Data (data of a photo)

            do {
                let model = try VNCoreMLModel(for: MobileNet().model) // assigning model to MobileNet.mlmodle
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod) // request from model(The brain of the model)
                let handler = VNImageRequestHandler(data: photoData!) // connet the picture's data with the model's brain.
                try handler.perform([request])

            } catch {
                debugPrint(error)
            }

            let image = UIImage(data: photoData!) // turns the photo data into Image "UIImage"
            self.captureView.image = image // assign the Image we got to the Image view "captureView"
        }
    }

}
    // MARK: - SpeechSynthesizer Delegate
extension ViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.camView.isUserInteractionEnabled = true // enables taking a picture again
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
        
        
    }
}


