//
//  ViewController.swift
//  seaFood
//
//  Created by adham ragap on 24/02/2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
    }
     
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        takePhoto()
    }
    func takePhoto (){
        let alert = UIAlertController(title: "you would like take photo from", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.takingPhoto(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "photo Library", style: .default, handler: { action in
            self.takingPhoto(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
       present(alert, animated: true, completion: nil)
    }
    func takingPhoto (sourceType:UIImagePickerController.SourceType){
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPikedImage = info[.originalImage] as? UIImage
        else {
            return
        }
        guard let ciImage = CIImage(image: userPikedImage) else {
             fatalError("cannot convert image to ci Image")
        }
        detect(image: ciImage)
        imageView.image = userPikedImage
        dismiss(animated: true, completion: nil)
    }
    func detect (image :CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading coreMl model failed.")
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to process image")
            }
            if let firstResult = results.first {
//                if firstResult.identifier.contains("hot dog") {
//                    self.navigationItem.title = "hot dog"
//                }else {
//                    self.navigationItem.title = "Not hot dog"
//                }
                self.navigationItem.title = firstResult.identifier
                
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
       
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

