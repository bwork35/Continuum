//
//  PhotoSelectorViewController.swift
//  Continuum
//
//  Created by Bryan Workman on 7/1/20.
//

import UIKit

class PhotoSelectorViewController: UIViewController & UINavigationControllerDelegate {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var selectImageButtonLabel: UIButton!
    
    weak var delegate: PhotoSelectorViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        postImageView.image = nil
        selectImageButtonLabel.setTitle("Select Image", for: .normal)
    }

    @IBAction func selectImageButtonTapped(_ sender: Any) {
        selectImageButtonLabel.setTitle("", for: .normal)
        
        let alertController = UIAlertController(title: "Select an image", message: "Where do you want to pick your image from", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        alertController.addAction(libraryAction)
        alertController.addAction(cameraAction)
        present(alertController, animated: true)
    }
}

extension PhotoSelectorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {return}
        selectImageButtonLabel.setTitle("", for: .normal)
        postImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
        delegate?.photoSelectorViewControllerSelected(image: selectedImage)
    }
}

protocol PhotoSelectorViewControllerDelegate: AnyObject {
    func photoSelectorViewControllerSelected(image: UIImage)
}
