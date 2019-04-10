//
//  ArchivedGoals.swift
//  StreakTasks
//
//  Created by Stefan Stevanovic on 4/3/19.
//  Copyright © 2019 Joey Tawadrous. All rights reserved.
//

import UIKit
import CoreData
import SCLAlertView
import FontAwesome_swift


class ArchivedGoals: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var goals = [AnyObject]()
    
    
    
    /* MARK: Init
     /////////////////////////////////////////// */
    override func viewWillAppear(_ animated: Bool) {
        self.refreshData()
        
        tableView.reloadData()
        
        // Styling
        Utils.insertGradientIntoView(viewController: self)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    func refreshData() {
        self.goals.removeAll()
        var allGoals = CoreData.fetchCoreDataObject(Constants.CoreData.GOAL, predicate: "")
        allGoals = allGoals.reversed() // newest first
        if allGoals.count > 0 {
            for goal in allGoals {
                if goal.value(forKey: Constants.CoreData.ARCHIVED) as! Bool? ?? false {
                    self.goals.append(goal)
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    /* MARK: Table Functionality
     /////////////////////////////////////////// */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: GoalTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell") as? GoalTableViewCell
        if cell == nil {
            cell = GoalTableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "cell")
        }
        let goal = goals[indexPath.row]
        
        // Style
        cell!.selectionStyle = .none
        
        let name = goal.value(forKey: Constants.CoreData.NAME) as! String?
        cell.nameLabel!.text = name
        
        var tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: name!)
        let archivedTasks = CoreData.fetchCoreDataObject(Constants.CoreData.ARCHIEVE_TASK, predicate: name!)
        tasks.append(contentsOf: archivedTasks)
        cell.taskCountLabel!.text = String(tasks.count)
        
        let thumbnail = goal.value(forKey: Constants.CoreData.THUMBNAIL) as! String?
        cell.thumbnailImageView!.image = UIImage(named: thumbnail!)
        cell.thumbnailImageView!.image = cell.thumbnailImageView!.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        cell.thumbnailImageView!.tintColor = UIColor.white
        
        cell.updateConstraints()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get selected goal name
        let cell = tableView.cellForRow(at: indexPath) as! GoalTableViewCell
        let selectedGoal = cell.nameLabel!.text
        
        // Set goal name in defaults (so we can attach tasks to it later)
        Utils.set(key: Constants.LocalData.SELECTED_GOAL, value: selectedGoal!)
        Utils.set(key: Constants.LocalData.SELECTED_GOAL_INDEX, value: indexPath.row)
        
        // Show tasks view
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let tasksView = storyBoard.instantiateViewController(withIdentifier: Constants.Views.TASKS) as! Tasks
        tasksView.cameFromArchive = true
        self.show(tasksView as UIViewController, sender: tasksView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let emptyView = UIView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))
        
        if goals.count == 0 {
            
            let emptyImageView = UIImageView(frame: CGRect(x:0, y:0, width:150, height:150))
            emptyImageView.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.30)
            let emptyImage = Utils.imageResize(UIImage(named: "Hobbies")!, sizeChange: CGSize(width: 150, height: 150)).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            emptyImageView.image = emptyImage
            emptyImageView.tintColor = UIColor.white
            emptyView.addSubview(emptyImageView)
            
            let emptyLabel = UILabel(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width - 100, height:self.view.bounds.size.height))
            emptyLabel.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.53)
            emptyLabel.text = "Do you like cooking? Perhaps you're more fitness oriented? Or maybe you'd like more family time? Create a goal now!"
            emptyLabel.font = UIFont.GothamProRegular(size: 15.0)
            emptyLabel.textAlignment = NSTextAlignment.center
            emptyLabel.textColor = UIColor.white
            emptyLabel.numberOfLines = 5
            emptyView.addSubview(emptyLabel)
            
            self.tableView.backgroundView = emptyView
            
            return 0
        }
        else {
            self.tableView.backgroundView = emptyView
            return goals.count
        }
    }
}

