//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Bryan Workman on 6/30/20.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    var resultsArray: [Post] = []
    var isSearching: Bool = false
    var dataSource: [SearchableRecord] {
        return isSearching ? resultsArray : PostController.shared.posts
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self 
        fullSync(completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = PostController.shared.posts
        tableView.reloadData()
    }
    
    // MARK: - Helper Methods
    func fullSync(completion: ((Bool) -> Void)?) {
        PostController.shared.fetchAllPosts { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    //guard let posts = posts else {return}
                    //PostController.shared.posts = posts
                    self.tableView.reloadData()
                    completion?(posts != nil)
                case .failure(let error):
                    print("There was an error fetching Posts -- \(error) -- \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else {return UITableViewCell()}
        
        let post = dataSource[indexPath.row] as? Post
        
        cell.post = post
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC"{
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            guard let destinationVC = segue.destination as? PostDetailTableViewController else {return}
            let post = PostController.shared.posts[indexPath.row]
            destinationVC.post = post
        }
    }
}

//MARK - Extensions
extension PostListTableViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultsArray = PostController.shared.posts.filter({$0.matches(searchTerm: searchText)})
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = PostController.shared.posts
        tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
}
