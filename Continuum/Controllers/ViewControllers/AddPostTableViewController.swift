//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Bryan Workman on 6/30/20.
//

import UIKit

class AddPostTableViewController: UITableViewController & UINavigationControllerDelegate {

    @IBOutlet weak var postCaptionTextField: UITextField!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        postCaptionTextField.text = "" 
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let photo = selectedImage,
            let text = postCaptionTextField.text, !text.isEmpty else {return}
        
        PostController.shared.createPostWith(image: photo, caption: text) { (result) in
            switch result {
            case .success(_):
                print("Successfully Created Post")
            case .failure(let error):
                print("There was an error creating the contact -- \(error) -- \(error.localizedDescription)")
            }
        }
        self.tabBarController?.selectedIndex = 0
    }
        
    
    
    
        
    
    
    
    
    
    
    
    

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoSelector" {
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
        }
    }
}

extension AddPostTableViewController : PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
       selectedImage = image
    }
}
