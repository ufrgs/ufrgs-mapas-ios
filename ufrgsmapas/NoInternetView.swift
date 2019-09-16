//
//  NoInternetView.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 28/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import Foundation
import UIKit

class NoInternetView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    // MARK: - Initialiser
    
    class func fromNib() -> NoInternetView {
        return Bundle.main.loadNibNamed(String(describing: NoInternetView.self), owner: nil, options: nil)![0] as! NoInternetView
    }
    
    // MARK: - Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()

        configureSubtitle()
        configureButton()
    }
    
    // MARK: - Configuration methods
    
    private func configureCornerRadius() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 16.0
    }
    
    func configureSubtitle() {
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Não foi possível obter as\nlocalizações dos prédios"
    }
    
    private func configureButton() {
        
        // title
        tryAgainButton.setTitle("     Tentar novamente     ", for: .normal)
        tryAgainButton.tintColor = .darkGray
        if let font = UIFont(name: "AvenirNext-Medium", size: 17.0) {
            tryAgainButton.titleLabel?.font = font
        }
        
        // rounded corners
        tryAgainButton.clipsToBounds = true
        tryAgainButton.layer.cornerRadius = 8.0
        
        // border
        tryAgainButton.layer.borderWidth = 1.25
        tryAgainButton.layer.borderColor = UIColor.darkGray.cgColor
        
    }
    
    func setLoading(_ isLoading: Bool) {
        
        tryAgainButton.isHidden = isLoading
        
        if isLoading {
//            imageView.loadGif(name: "loading")
            imageView.image = nil
            titleLabel.text = "Carregando..."
            subtitleLabel.text = "\n"
            
        } else {
            imageView.image = UIImage(named: "noInternetIcon")
            titleLabel.text = "Sem conexão"
            subtitleLabel.text = "Não foi possível obter as\nlocalizações dos prédios"
        }
        
    }
    
}
