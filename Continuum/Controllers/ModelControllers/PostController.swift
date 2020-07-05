//
//  PostController.swift
//  Continuum
//
//  Created by Bryan Workman on 6/30/20.
//

import UIKit
import CloudKit

class PostController {
    
    //Shared Instance
    static let shared = PostController()
    
    //SOT
    var posts: [Post] = []
    
    //Public Cloud Database
    let publicDB = CKContainer.default().publicCloudDatabase
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
    //Methods
    func addComment(text: String, post: Post, completion: @escaping (Result<Comment, PostError>) -> Void) {
        
        let postReference = CKRecord.Reference(recordID: post.recordID, action: .none)
        
        let newComment = Comment(text: text, postReference: postReference)
        
        post.comments.append(newComment)
        
        updateCommentCount(for: post) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("Successfully updated comment count")
                case .failure(let error):
                    print("There was an error updating comment count -- \(error) -- \(error.localizedDescription)")
                }
            }
        }
        
        let commentRecord = CKRecord(comment: newComment)
        
        publicDB.save(commentRecord) { (record, error) in
            if let error = error {
                print("There was an error adding a comment: \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
            let comment = Comment(ckRecord: record) else {return completion(.failure(.couldNotUnwrap)) }
            
            print("Comment Saved Successfully")
            completion(.success(comment))
        }
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Result<Post?, PostError>) -> Void) {
        
        let newPost = Post(photo: image, caption: caption)
        
        self.posts.append(newPost)
        
        let postRecord = CKRecord(post: newPost)
        
        publicDB.save(postRecord) { (record, error) in
            if let error = error {
                print("There was an error saving a post: \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let post = Post(ckRecord: record) else {return completion(.failure(.couldNotUnwrap)) }
            
            print("Post Saved Successfully")
            completion(.success(post))
        }
    }
    
    func fetchAllPosts(completion: @escaping (Result<[Post]?, PostError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
       
        let query = CKQuery(recordType: PostConstants.recordTypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error fetching all Posts -- \(error) -- \(error.localizedDescription)")
                completion(.failure(.ckError(error)))
            }
            
            guard let records = records else {return completion(.failure(.couldNotUnwrap))}
            
            print("Fetched Post Records Successfully")
            
            let fetchedPosts = records.compactMap { Post(ckRecord: $0) }
            
            self.posts = fetchedPosts

            completion(.success(fetchedPosts))
        }
    }
    
    func fetchComments(for post: Post, completion: @escaping (Result<[Comment]?, PostError>) -> Void) {
        
        let postRefence = post.recordID
        
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postRefence)
        
        let commentIDs = post.comments.compactMap({$0.recordID})
        
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let query = CKQuery(recordType: CommentConstants.recordTypeKey, predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error fetching comments -- \(error) -- \(error.localizedDescription)")
                completion(.failure(.ckError(error)))
            }
            
            guard let records = records else {return
                completion(.failure(.couldNotUnwrap))}
            
            print("Fetched Comment Records Successfully")
            
            let fetchedComments = records.compactMap { Comment(ckRecord: $0) }
            
            post.comments.append(contentsOf: fetchedComments)
            
            completion(.success(fetchedComments))
        }
    }
    
    func updateCommentCount(for post: Post, completion: @escaping (Result<Bool, PostError>) -> Void) {
        
        post.commentCount = post.comments.count
        
        let record = CKRecord(post: post)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            
            if let error = error {
                print("There was an error modifying the Comment Count -- \(error) -- \(error.localizedDescription)")
                return completion(.failure(.ckError(error)))
            } else {
                completion(.success(true))
            }
        }
        publicDB.add(operation)
    }
    
    //MARK: - Subscriptions
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?) {
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: PostConstants.recordTypeKey, predicate: predicate, subscriptionID: "AllPosts", options: CKQuerySubscription.Options.firesOnRecordCreation)
        
        let notificationInfo = CKQuerySubscription.NotificationInfo()
        notificationInfo.title = "Continuum"
        notificationInfo.alertBody = "New post added"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        notificationInfo.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                print("There was an error subscribing to post creations - \(error) - \(error.localizedDescription)")
                completion?(false, error)
                return
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func addSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?) {
        
        let postRecordID = post.recordID
        
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postRecordID)
        
        let subscription = CKQuerySubscription(recordType: CommentConstants.recordTypeKey, predicate: predicate, subscriptionID: post.recordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
        
        let notificationInfo = CKQuerySubscription.NotificationInfo()
        notificationInfo.title = "Continuum"
        notificationInfo.alertBody = "New comment added."
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        notificationInfo.desiredKeys = [CommentConstants.textKey, CommentConstants.timestampKey]
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print("There was an error subscribing to comments - \(error) - \(error.localizedDescription)")
                completion?(false, error)
                return
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?) {
        
        let subscriptionID = post.recordID.recordName
        
        publicDB.delete(withSubscriptionID: subscriptionID) { (_, error) in
            if let error = error {
                print("There was an error removing the subscription - \(error) - \(error.localizedDescription)")
                completion?(false, error)
                return
            } else {
                print("Subscription deleted")
                completion?(true, nil)
            }
        }
    }
    
    func checkSubscription(to post: Post, completion: ((Bool) -> ())?) {
        
        let subscriptionID = post.recordID.recordName
        
        publicDB.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            if let error = error {
                print("There was an error checking subscription -- \(error) -- \(error.localizedDescription)")
                completion?(false)
                return
            }
            
            if subscription != nil {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?) {
        
        checkSubscription(to: post) { (result) in
            switch result {
            case true:
                self.removeSubscriptionTo(commentsForPost: post) { (success, error) in
                    if let error = error {
                        print("There was an error removing subscription to comments --\(error) -- \(error.localizedDescription)")
                        completion?(false, error)
                        return
                    }
                    
                    if success {
                        print("Success removing subscription to comments.")
                        completion?(true, nil)
                    } else {
                        print("There was an error removing subscription to comments")
                        completion?(false, nil)
                    }
                }
            case false:
                self.addSubscriptionTo(commentsForPost: post) { (success, error) in
                    if let error = error {
                        print("There was an error subscribing to comments -\(error) --\(error.localizedDescription)")
                        completion?(false, error)
                        return
                    }
                    
                    if success {
                        print("Successfully subscribed to comments.")
                        completion?(true, nil)
                    } else {
                        print("There was an error subscribing to comments")
                        completion?(false, nil)
                    }
                }
            }
        }
    }
}
