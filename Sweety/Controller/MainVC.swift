//
//  ViewController.swift
//  Sweety
//
//  Created by Burak İmdat on 20.11.2021.
//

import UIKit
import Firebase
import FirebaseAuth

class MainVC: UIViewController {

    @IBOutlet weak var sgmCategories: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var ideas: [Idea] = [Idea]()
    
    private var IdeasCollectionRef: CollectionReference!
    private var ideasListener: ListenerRegistration!
    private var listenerHandle: AuthStateDidChangeListenerHandle!

    private var selectedCategory = Category.FUNNY.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        IdeasCollectionRef = Firestore.firestore().collection(IDEA_REF)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(identifier: "LoginVC")
                loginVC.modalPresentationStyle = .fullScreen
                
                self.present(loginVC, animated: true, completion: nil)
            } else {
                self.setListener()
            }
        }
        
        
    }
    
    func setListener() {
        if selectedCategory == Category.POPULAR.rawValue {
            ideasListener = IdeasCollectionRef.newWhere().addSnapshotListener { (snapshot, err) in
                if let err = err {
                    debugPrint("Error when is getting data: \(err.localizedDescription)")
                } else {
                    self.ideas.removeAll()
                    self.ideas = Idea.getIdeas(snapshot: snapshot)
                    self.tableView.reloadData()
                }
            }
        } else {
            ideasListener = IdeasCollectionRef.whereField(CATEGORY, in: [selectedCategory]).order(by: PUBLISH_DATE, descending: true).addSnapshotListener { (snapshot, err) in
                if let err = err {
                    debugPrint("Error when is getting data: \(err.localizedDescription)")
                } else {
                    self.ideas.removeAll()
                    self.ideas = Idea.getIdeas(snapshot: snapshot, byLikeCount: true)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if ideasListener != nil {
            ideasListener.remove()
        }
        
    }

    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedCategory = Category.FUNNY.rawValue
        case 1:
            selectedCategory = Category.NEWS.rawValue
        case 2:
            selectedCategory = Category.ABSURD.rawValue
        case 3:
            selectedCategory = Category.POPULAR.rawValue
        default:
            selectedCategory = Category.FUNNY.rawValue
        }
        ideasListener.remove()
        setListener()
    }
    
    @IBAction func LogoutClicked(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            
        } catch {
            debugPrint("Error when is logging out user : \(error.localizedDescription)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            if let destinationVC = segue.destination as? CommentVC {
                if let selectedIdea = sender as? Idea {
                    destinationVC.selectedIdea = selectedIdea
                }
            }
        }
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideas.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "IdeaCell", for: indexPath) as? IdeaCell {
            cell.setView(idea: ideas[indexPath.row], delegate: self)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CommentSegue", sender: ideas[indexPath.row])
    }
}

extension MainVC: IdeaDelegate {
    func ideaSettingsClicked(idea: Idea) {
        let alert = UIAlertController(title: "Delete", message: "Do you want delete your post ?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Yes, delete it", style: .destructive) { action in
            let commentsCollRef = Firestore.firestore().collection(IDEA_REF).document(idea.documentId).collection(COMMENT_REF)
            let likesCollRef = Firestore.firestore().collection(IDEA_REF).document(idea.documentId).collection(LIKE_REF)
            
            self.deleteCollection(collection: likesCollRef) { error in
                if let error = error {
                    debugPrint("Error in batch: \(error.localizedDescription)")
                } else {
                Firestore.firestore().collection(IDEA_REF).document(idea.documentId).delete { error in
                if let error = error {
                    print("Erorr when likes is deleting :\(error.localizedDescription) ")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
 
                }
            }
            
            self.deleteCollection(collection: commentsCollRef) { error in
                if let error = error {
                    debugPrint("Error in batch: \(error.localizedDescription)")
                } else {
                Firestore.firestore().collection(IDEA_REF).document(idea.documentId).delete { error in
                if let error = error {
                    print("Erorr when comment is deleting :\(error.localizedDescription) ")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
 
                }
            }
       }
        let cancelAction = UIAlertAction(title: "No, cancel it", style: .cancel) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    func deleteCollection(collection: CollectionReference, deleteCommentCount: Int = 50, completion: @escaping (Error?) -> ()){
        collection.limit(to: deleteCommentCount).getDocuments { (datas, error) in
            guard let datas = datas else {
                completion(error)
                return
            }
            guard datas.count > 0 else {
                completion(nil)
                return
            }
            let batch = collection.firestore.batch()
            
            datas.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { error in
                if let error = error {
                    completion(error)
                } else {
                    self.deleteCollection(collection: collection, deleteCommentCount: deleteCommentCount, completion: completion)
                }
            }
        }
    }
}
