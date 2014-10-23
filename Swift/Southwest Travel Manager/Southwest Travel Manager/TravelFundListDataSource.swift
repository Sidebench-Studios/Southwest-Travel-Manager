//
//  TravelFundListDataSource.swift
//  Southwest Travel Manager
//
//  Created by Colin Regan on 10/21/14.
//  Copyright (c) 2014 Red Cup. All rights reserved.
//

import UIKit
import Realm

class TravelFundListDataSource: ListDataSource {
    
    override init() {
        super.init()
        // TODO: feature -- show used funds, expired funds
        array = [TravelFund.objectsWhere("balance > 0 && expirationDate > %@", NSDate()).arraySortedByProperty("expirationDate", ascending: true)]
    }
    
    func travelFundAtIndexPath(indexPath: NSIndexPath) -> TravelFund? {
        return objectAtIndexPath(indexPath) as? TravelFund
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let superRows = super.tableView(tableView, numberOfRowsInSection: section)
        let showSummaryRow = (section == 0)
        return superRows + Int(showSummaryRow)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (array?[indexPath.section].count > UInt(indexPath.row)) {
            let travelFund = array?[indexPath.section].objectAtIndex(UInt(indexPath.row)) as TravelFund
            let cell = tableView.dequeueReusableCellWithIdentifier("travelFundCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = travelFund.balance.currencyValue
            if let confirmationCode = travelFund.originalFlight?.confirmationCode {
                cell.detailTextLabel?.text = confirmationCode + " (" + NSDateFormatter.localizedStringFromDate(travelFund.expirationDate, dateStyle: .ShortStyle, timeStyle: .NoStyle) + ")"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = "Summary!"
            return cell
        }
    }
}
