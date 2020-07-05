//
//  UIViewControllerExtension.swift
//  Continuum
//
//  Created by Bryan Workman on 7/3/20.
//

import UIKit

extension UIViewController {
    func presentSimpleAlertWith(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        present(alertController, animated: true)
    }
}
