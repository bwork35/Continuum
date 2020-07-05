//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Bryan Workman on 6/30/20.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postCaptionLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let post = post else {return}
        postImageView.image = post.photo
        postCaptionLabel.text = post.caption
        commentCountLabel.text = "\(post.commentCount)"
    }
}
