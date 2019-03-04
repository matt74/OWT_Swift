//
//  MainViewController.swift
//  OWT_Swift
//
//  Created by Matthias BUREL on 03.03.19.
//  Copyright © 2019 Matthias BUREL. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class MainViewController:UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet private weak var tableView: UITableView!
    private var headerViewController: MainHeaderViewController?
    private var dataArray: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "OWT"
        
        refreshUI()

        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI),
                                               name: NSNotification.Name(rawValue: "URL_DATA_UPDATED_NOTIFICATION"), object: nil)

        AppDelegate().importDemoData()
        
    }
    
    @objc func refreshUI() {
        refreshData()
        tableView.reloadData()
        highlightCell()
    }
    
    func refreshData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "URL")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 365
        request.returnsObjectsAsFaults = false
        do {
            dataArray = try context.fetch(request)
        } catch {}
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: URLTableViewCell_ID) as? URLTableViewCell

        return cell!
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? URLTableViewCell)?.configWithURL(aUrl: dataArray[indexPath.row] as! NSManagedObject)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let urlFromObject = dataArray[indexPath.row] as! NSManagedObject
        let urlString = urlFromObject.value(forKey: "url") as? String
        
        guard let url = URL(string: urlString ?? "") else { return }
        UIApplication.shared.open(url)
    }

    func highlightCell() {

        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? URLTableViewCell
        UIView.animate(withDuration: 0.1, animations: {
            // hide
            cell?.alpha = 0.0
        }) { finished in
            // show after hiding
            UIView.animate(withDuration: 2.0, animations: {
                cell?.alpha = 1.0
            }) {
                finished in
            }
        }
    }
    
}
