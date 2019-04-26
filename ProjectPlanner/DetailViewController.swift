//
//  DetailViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/26/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController
{

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView()
    {
        // Update the user interface for the detail item.
        if let detail = detailItem
        {
            if let label = detailDescriptionLabel
            {
                label.text = detail.name
            }
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: Project?
    {
        didSet
        {
            // Update the view.
            configureView()
        }
    }


}

