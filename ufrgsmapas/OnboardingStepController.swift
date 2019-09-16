//
//  OnboardingStepController.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 20/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import Foundation
import UIKit

class OnboardingStepController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.clipsToBounds = true
    }
    
    func configure(image: UIImage?, title: String, text: String) {
        self.imageView.image = image
        self.titleLabel.text = title
        self.infoLabel.text = text
    }
    
}
