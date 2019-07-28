//
//  LibraryController.swift
//  Techlo
//
//  Created by Florian on 11/6/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import BouncyLayout

class NoteController: CollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let emptyId = "emptyId"
    
    var notes = [Note]()
    var isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        pageNotes()
    }
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        self.edgesForExtendedLayout = UIRectEdge.bottom
        setupCollectionView()
        
        navigationItem.title = "Appointment Notes"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
    }
    
    func setupCollectionView(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.decelerationRate = .fast
        collectionView?.backgroundColor = ColorModel.returnWhite()
        collectionView.scrollsToTop = true
        collectionView?.register(NotePreviewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: emptyId)
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: -10, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == self.notes.count - 1 && !isFinishedPaging {
            pageNotes()
        }
        
        if notes.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyId, for: indexPath) as! EmptyCell
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NotePreviewCell
        cell.note = notes[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
   //     if notes.count > 0 {
            return CGSize(width: view.frame.size.width, height: view.frame.size.height * 0.1)
//        } else {
//            return view.frame.size
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if notes.count == 0 {
            return
        }
        
        let fullNoteController = FullNoteController()
        fullNoteController.note = notes[indexPath.item]
        self.navigationController?.pushViewController(fullNoteController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if notes.count == 0 {
            return 1
        }
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc func handleRefresh() {
        print("Handling refresh..")
        notes.removeAll()
        pageNotes()
    }
    
    func pageNotes(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child(FirebaseKey.note.rawValue).child(uid)
        var query = ref.queryOrdered(byChild: "date")
        
        if notes.count > 0 {
            let value = notes.last?.date.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 8).observe(.value, with: { (snapshot) in
            self.collectionView.refreshControl?.endRefreshing()
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 8 {
                self.isFinishedPaging = true
            }
            
            if self.notes.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                
//                guard let dictionaries = snapshot.value as? [String: Any] else { return }
//                print(dictionaries)
//                dictionaries.forEach({ (key, value) in
//
//                    guard let dictionary = value as? [String: Any] else {print("cant cast value to dict"); return }
//                   // print(dictionary)
//                    let note = Note(dictionary: dictionary)
//                   // print(note)
//                    self.notes.append(note)
//                })
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var note = Note(dictionary: dictionary)
                note.identifier = snapshot.key
                self.notes.append(note)
                self.collectionView?.reloadData()
            })
            
            self.collectionView?.reloadData()

        }) { (error) in
            print("Failed to query paginate for user appointments: ", error)
        }
    }
    
    func zoomInOnPicture(imageView: UIImageView) {
        self.performZoomInForStartingImageView(imageView)
    }
}
