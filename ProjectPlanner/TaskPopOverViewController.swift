//
//  TaskPopOverViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 5/13/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit

class TaskPopOverViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    func showPopover(task: Task)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let popoverViewController = storyboard.instantiateViewController(withIdentifier: "TaskViewController") as UIViewController?
        popoverViewController?.modalPresentationStyle = .popover
        popoverViewController?.preferredContentSize = CGSize.init(width: 400, height: 700)
        
        let popoverPresentationViewController = popoverViewController?.popoverPresentationController
        
        popoverPresentationViewController?.permittedArrowDirections = UIPopoverArrowDirection.left
        //popoverPresentationViewController?.sourceView = button
        //popoverPresentationViewController?.sourceRect = button.bounds
        
        self.present(popoverViewController!, animated: true, completion: nil)
    }

}
