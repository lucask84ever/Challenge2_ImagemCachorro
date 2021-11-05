//
//  ViewController.swift
//  Challenge2_ImagemCachorro
//
//  Created by Lucas Angeli Lima on 03/11/21.
//

import UIKit

enum DogError: Error {
    case badUrl
    case parseError
    case unknownError
    case otherError(Error)
}

class ViewController: UIViewController {

    @IBOutlet weak var dogImageView: UIImageView!
    @IBOutlet weak var _activityIndicator: UIActivityIndicatorView!
    
    let urlDefault = "https://dog.ceo/api/breeds/image/random"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestNewDog()
        
    }
    
    func requestNewDog() {
        _activityIndicator.startAnimating()
        requestDogImage { [weak self] result in
            switch result {
            case .success(let dog):
                self?.dogImageView.downloadImage(dog.message) { isLoading in
                    if !isLoading {
                        self?._activityIndicator.stopAnimating()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func requestDogImage(completion: @escaping(Result<DogImage, DogError>) -> Void) {
        let session = URLSession.shared
        guard let url = URL(string: urlDefault) else { return }
        
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(DogError.otherError(error)))
            }
            guard let data = data else {
                completion(.failure(.unknownError))
                return
            }
            do {
                let dogImage = try JSONDecoder().decode(DogImage.self, from: data)
                completion(.success(dogImage))
            } catch {
                completion(.failure(.parseError))
            }
        }.resume()
    }
    
    @IBAction func anotherDog() {
        dogImageView.image = nil
        requestNewDog()
    }
    
}
    

extension UIImageView {
    
    func downloadImage(_ url: String, completion: @escaping( (Bool) -> Void)) {
        let session = URLSession.shared
        guard let url = URL(string: url) else {
            return
        }
        session.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else {
                completion(false)
                return
            }
                
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self?.image = image
                completion(false)
            }
        }.resume()
    }
}

class DogImage: Codable {
    let message: String
}
