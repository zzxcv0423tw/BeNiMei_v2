//
//  Calendar.swift
//  BeNiMei
//
//  Created by user149927 on 1/8/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Firebase



class CalendarViewController: UIViewController{
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    
    let outsideMonthColor = UIColor(displayP3Red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
    let monthColor = UIColor.black
    let selectedMonthColor = UIColor.black
    let currectDateSelectedViewColor = UIColor(red:0.31, green:0.25, blue:0.36, alpha:1.0)
    
    let formatter = DateFormatter()
    
    var bGyellow: UIColor = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.8, alpha: 1.0)
    var bGwhite: UIColor = UIColor.white
    var bGKey: Int = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupCalnderView()
        let navBackgroundImage = UIImage(named: "topbar_500_120")
        self.navigationController!.navigationBar.setBackgroundImage(navBackgroundImage, for: .default)
    }
    
    
    
    func setupCalnderView(){
        // Setup Calendar Spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        // Setup Labels
        calendarView.visibleDates{(visibleDates) in
            self.setupViewsofCalendar(from: visibleDates)
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?,cellState: CellState){
        guard let validCell = view as? CustomCell else {return}
        if cellState.isSelected{
            validCell.dateLabel.textColor = selectedMonthColor
        }
        else {
            if cellState.dateBelongsTo == .thisMonth{
                validCell.dateLabel.textColor = monthColor
            } else {
                validCell.dateLabel.textColor = outsideMonthColor
            }
            validCell.selectedView.isHidden = true
        }
    }
    
    func handleCellSelected(view: JTAppleCell?,cellState: CellState){
        guard let validCell = view as? CustomCell else {return}
        if cellState.isSelected{
            validCell.selectedView.isHidden = false
        }
        else {
            validCell.selectedView.isHidden = true
        }
    }
    
    func setupViewsofCalendar(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        self.formatter.dateFormat = "yyyy"
        self.year.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "M"
        self.month.text = self.formatter.string(from: date) + "月"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource{
    
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat="yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale

        let startDate = formatter.date(from: "2019 01 01")!
        let endDate = formatter.date(from: "2019 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
}

extension CalendarViewController: JTAppleCalendarViewDelegate{
    // display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        switch cellState.day {
        case DaysOfWeek.sunday, DaysOfWeek.tuesday, DaysOfWeek.thursday, DaysOfWeek.saturday:
            cell.backgroundColor = bGwhite
        default:
            cell.backgroundColor = bGyellow
        }
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        return cell
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsofCalendar(from: visibleDates)
    }
}
