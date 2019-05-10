//
//  TaskTableViewCell.swift
//  ProjectPlanner
//
//  Created by user153198 on 5/8/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell
{

//    @IBOutlet weak var txtView_note: UITextView!
//    @IBOutlet weak var label_notify: UILabel!
//    @IBOutlet weak var label_startDate: UILabel!
//    @IBOutlet weak var label_title: UILabel!
//    @IBOutlet weak var progressBar_task: CircularProgressBar!
    
    var task: Task?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
