//
//  Post.swift
//  Continuum
//
//  Created by Bryan Workman on 6/30/20.
//

import CloudKit
import UIKit

struct PostConstants {
    static let recordTypeKey = "Post"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let captionKey = "caption"
    fileprivate static let commentsKey = "comments"
    fileprivate static let commentCountKey = "commentCount"
    fileprivate static let photoKey = "photo"
}

class Post {
    
    var photoData: Data?
    var timestamp: Date
    var caption: String
    var comments: [Comment]
    var recordID: CKRecord.ID
    var commentCount: Int
    var photo: UIImage? {
        get {
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirecotryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirecotryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            
            do {
                try photoData?.write(to: fileURL)
                
            } catch {
                print("Error writing to temp url \(error) \(error.localizedDescription)")
                    
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(photo: UIImage? = nil, caption: String, timestamp: Date = Date(), comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), commentCount: Int = 0){
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.commentCount = commentCount
        self.recordID = recordID
        self.photo = photo
    }
}

extension Post {
    
    convenience init?(ckRecord: CKRecord){
        guard let caption = ckRecord[PostConstants.captionKey] as? String,
            let timestamp = ckRecord[PostConstants.timestampKey] as? Date,
            let commentCount = ckRecord[PostConstants.commentCountKey] as? Int else {return nil}
        
        var foundPhoto: UIImage?
        
        if let photoAsset = ckRecord[PostConstants.photoKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Failed to transform asset to data - \(error) - \(error.localizedDescription)")
            }
        }
        self.init(photo: foundPhoto, caption: caption, timestamp: timestamp, comments: [], recordID: ckRecord.recordID, commentCount: commentCount)
    }
}

extension CKRecord {
    convenience init(post: Post){
        self.init(recordType: PostConstants.recordTypeKey, recordID: post.recordID)
        
        self.setValuesForKeys([
            PostConstants.timestampKey : post.timestamp,
            PostConstants.captionKey : post.caption,
            PostConstants.commentCountKey : post.commentCount
            
        ])
        
        if post.imageAsset != nil {
            self.setValue(post.imageAsset, forKeyPath: PostConstants.photoKey)
        }
    }
}

extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if caption.contains(searchTerm) {
            return true
        } else {
            return false
        }
    }
}
