//
//  URLTableViewCell.swift
//  OWT_Swift
//
//  Created by Matthias BUREL on 03.03.19.
//  Copyright © 2019 Matthias BUREL. All rights reserved.
//

import UIKit
import CoreData

let URLTableViewCell_ID = "URLTableViewCellID"

class URLTableViewCell: UITableViewCell  {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var urlLabel: UILabel!
    @IBOutlet private weak var tinyLabel: UILabel!
    @IBOutlet private weak var demoRecordLabel: UILabel!
    private var formatter: DateFormatter?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        formatter = DateFormatter()
        formatter?.dateStyle = .medium
        formatter?.timeStyle = .short
    }

    func configWithURL(aUrl: NSManagedObject) {

        let date = aUrl.value(forKey: "date") as! Date
        let dns = aUrl.value(forKey: "dns") as? String
        let token = aUrl.value(forKey: "token") as? String
            
        dateLabel.text = formatter?.string(from: date)
        urlLabel.text = aUrl.value(forKey: "url") as? String
        tinyLabel.text = String(format: "%@/%@", dns!, token!)
    
        if (aUrl.value(forKey: "isDemo") as? Bool)! {
            demoRecordLabel.textColor = UIColor.red
            demoRecordLabel.text = "#Demo record"
        } else {
            demoRecordLabel.textColor = UIColor(red: 48.0 / 255.0, green: 146.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            demoRecordLabel.text = "#Real record"
        }
    }
}
