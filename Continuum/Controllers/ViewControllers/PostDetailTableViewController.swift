//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Bryan Workman on 6/30/20.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var followPostButtonOutlet: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    //MARK: - Properties
    var post: Post? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchComments()
    }
    
    //MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "New Comment", message: "Whatcha wanna say?", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter new comment..."
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else {return}
            
                if let post = self.post {
                   
                //REMEMBER TO COME BACK AND CHECK IF THIS IS RIGHT
                PostController.shared.addComment(text: text, post: post) { (result) in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let comment = post?.caption else {return}
        let shareSheet = UIActivityViewController(activityItems: [comment], applicationActivities: nil)
        present(shareSheet, animated: true, completion: nil)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        guard let post = post else {return}
        PostController.shared.toggleSubscriptionTo(commentsForPost: post) { (result, error) in
            if let error = error {
                print("There was an error toggling subscription for post --\(error) --\(error.localizedDescription)")
                return
            }
            self.updateViews()
        }
    }
    
    //MARK: - Helper Methods
    func updateViews() {
        guard let post = post else {return}
        DispatchQueue.main.async {
            self.photoImageView.image = post.photo
        }
        
        PostController.shared.checkSubscription(to: post) { (result) in
            DispatchQueue.main.async {
                switch result {
                case true:
                    self.followPostButtonOutlet.setTitle("Unfollow Post", for: .normal)
                case false:
                    self.followPostButtonOutlet.setTitle("Follow Post", for: .normal)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchComments() {
        guard let post = post else {return}
        PostController.shared.fetchComments(for: post) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.tableView.reloadData()
                case .failure(let error):
                    print("There was an error fetching comments for this post -- \(error) -- \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let post = post else {return 0}
        return post.comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        guard let post = post else {return UITableViewCell()}
        
        let comment = post.comments[indexPath.row]
        
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = comment.timestamp.dateAsString()
        
        return cell
    }
}
