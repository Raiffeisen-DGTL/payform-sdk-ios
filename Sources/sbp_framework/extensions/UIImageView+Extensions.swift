//
//  UIImageView+Extensions.swift
//  raiffeisenSDK
//
//  Created by Sergey Panov on 28.09.2022.
//

import UIKit

extension UIImageView {
    func download(from url: URL?, contentMode mode: UIView.ContentMode = .scaleAspectFit) -> URLSessionDataTask? {
        guard let url = url else { return nil }
        contentMode = mode
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }
        task.resume()
        return task
    }
    
    func download(from link: String?, contentMode mode: UIView.ContentMode = .scaleAspectFit) -> URLSessionDataTask? {
        guard let url = URL(string: link ?? "") else { return nil }
        return download(from: url, contentMode: mode)
    }
}
