import UIKit
import SwiftyJSON


class ProgressManager {
	
	class func getAchievements() -> [Any] {
		var achievements: [Any] = []
		
		if Utils.appData()[Constants.Defaults.APP_DATA_ACHIEVEMENTS] != JSON.null {
			achievements = Utils.appData()[Constants.Defaults.APP_DATA_ACHIEVEMENTS].arrayObject!
		}
		
		return achievements
	}
	
	
	class func isAchievementReached(name: String) -> Bool {
		let achievements = getAchievements()
		
		for achievement in achievements {
			if (achievement as! [String: String])["name"]! == name {
				return true
			}
		}
		
		return false
	}
	
	
	class func checkAchivementReached(view: UIViewController, achievement: [String]) {
		var achievementReached = false
		
		for userAchievement in getAchievements() {
			if JSON(userAchievement)["name"].string! == achievement[0] {
				achievementReached = true
			}
		}
		
		if !achievementReached { setAchievementReached(view: view, achievement: achievement) }
	}
	
	
	class func checkAndSetAchievementReached(view: UIViewController, type: String) {
		if type == Constants.Achievements.POINTS_TYPE {
			for achievement in Constants.Achievements.ACHIEVEMENTS_POINTS {
				let value = Int(achievement[0].components(separatedBy: "p")[0])
				if Utils.int(key: Constants.Defaults.APP_DATA_TOTAL_POINTS) >= value! {
					checkAchivementReached(view: view, achievement: achievement)
				}
			}
		}
		else if type == Constants.Achievements.GOALS_TYPE {
			for achievement in Constants.Achievements.ACHIEVEMENTS_GOALS {
				let value = Int(achievement[0].components(separatedBy: "g")[0])
				if Utils.int(key: Constants.Defaults.APP_DATA_TOTAL_GOALS_CREATED) >= value! {
					checkAchivementReached(view: view, achievement: achievement)
				}
			}
		}
		else if type == Constants.Achievements.TASKS_TYPE {
			for achievement in Constants.Achievements.ACHIEVEMENTS_TASKS {
				let value = Int(achievement[0].components(separatedBy: "t")[0])
				if Utils.int(key: Constants.Defaults.APP_DATA_TOTAL_TASKS_COMPLETED) >= value! {
					checkAchivementReached(view: view, achievement: achievement)
				}
			}
		}
	}
	
	
	class func setAchievementReached(view: UIViewController, achievement: [String]) {
		var achievements = getAchievements()
		
		let newAchievement: Any = [
			"name": achievement[0],
			"date": Utils.getCurrentDateString()
		]
		
		achievements.append(newAchievement)
		Utils.setAppData(key: Constants.Defaults.APP_DATA_ACHIEVEMENTS, json: JSON(achievements))
		
		Dialogs.showAchievementDialog(view: view, reached: true, achievement: achievement)
	}
	
	
	class func getLevel(points: Int) -> Int {
		var i = 0
		for levelThreshold in Constants.Strings.LEVEL_THRESHOLDS {
			if levelThreshold > points {
				return i
			}
			i = i + 1
		}
		return 0
	}
	
	
	class func getLevelProgress(points: Int) -> Double {
		return Double(Double(points) / Double(Constants.Strings.LEVEL_THRESHOLDS[getLevel(points: points)]))
	}
	
	
	class func shouldLevelUp(points: Int) -> Bool {
		for levelThreshold in Constants.Strings.LEVEL_THRESHOLDS {
			if levelThreshold > points && levelThreshold <= (points + 3) {
				return true
			}
		}
		return false
	}
}
