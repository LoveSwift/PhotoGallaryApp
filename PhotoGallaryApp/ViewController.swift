//
//  ViewController.swift
//  Flicker_iOS_search
//
//  Created by Suryakant Sharma-Pro on 06/09/20.
//  Copyright © 2020 . All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Variables
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var text: String?
    private var photos: Photos?
    private var isLoading: Bool = false
    private var photoArray: [Photo] = []
    private var photoManager = PhotoManager()
    private var searchTask: DispatchWorkItem?
    
    // MARK :- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.delegate = nil
        collectionView.dataSource = nil
    }
    
    func fetchphotos(text: String, pageCount: Int) {
        self.photoManager
            .fetchPhotos(text: text, pageCount: pageCount) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    do {
                        self.photos = try result.get()
                        self.photoArray.append(contentsOf: self.photos?.photos.photo ?? [])
                        print(result)
                        self.collectionView.delegate = self
                        self.collectionView.dataSource = self
                        self.collectionView.reloadData()
                        self.isLoading = false
                    } catch {
                        print(error.localizedDescription)
                        // Show error view
                }
            }
        }
    }
}

// MARK :- CollectionView Data Source Delegates
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCollectionViewCell.self), for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let photoURL = photoArray[safe: indexPath.item]?.getImagePath() else {
            return cell
        }
        cell.imageView.image = #imageLiteral(resourceName: "placeholder")
        cell.imageView.urlString = photoURL.absoluteString
        cell.imageView.loadImage(urlString: photoURL.absoluteString)
        return cell
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == photoArray.count - 1,
            !isLoading {
            isLoading = true
            // Detect end of scrolling load more cells
            guard let text = text else { return }
            fetchphotos(text: text, pageCount: photos!.photos.page + 1)
        }
    }
}


extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         guard !searchText.isEmpty else { return }
        self.text = searchText
        // Cancel previous task
        searchTask?.cancel()
        let newTask = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.photoArray.removeAll()
            self.collectionView.reloadData()
            self.collectionView.setContentOffset(.zero, animated: true)
            self.fetchphotos(text: searchText, pageCount: 1)
        }
        self.searchTask = newTask
        // Add throtteling of 0.75 seconds
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: newTask)
    }
}
