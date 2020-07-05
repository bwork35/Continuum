//
//  Comment.swift
//  Continuum
//
//  Created by Bryan Workman on 6/30/20.
//

import Foundation
import CloudKit

struct CommentConstants {
    static let recordTypeKey = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postReferenceKey = "post"
}

class Comment {
    
    var text: String
    var timestamp: Date
    //weak var post: Post?
    let recordID: CKRecord.ID
    var postReference: CKRecord.Reference?
    
    init(text: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), postReference: CKRecord.Reference?) {
        self.text = text
        self.timestamp = timestamp
        //self.post = post
        self.recordID = recordID
        self.postReference = postReference
    }
}

extension Comment {
    convenience init?(ckRecord: CKRecord) {
        guard let text = ckRecord[CommentConstants.textKey] as? String,
        let timestamp = ckRecord[CommentConstants.timestampKey] as? Date else {return nil}
        
        let postReference = ckRecord[CommentConstants.postReferenceKey] as? CKRecord.Reference
            
        self.init(text: text, timestamp: timestamp, recordID: ckRecord.recordID, postReference: postReference)
    }
}

extension CKRecord {
    convenience init(comment: Comment){
        self.init(recordType: CommentConstants.recordTypeKey, recordID: comment.recordID)
        
        self.setValuesForKeys([
            CommentConstants.textKey : comment.text,
            CommentConstants.timestampKey : comment.timestamp
        ])
        
        if let reference = comment.postReference {
            self.setValue(reference, forKey: CommentConstants.postReferenceKey)
        }
    }
}
