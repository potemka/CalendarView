//
//  CalendarDay.swift
//  CalendarView
//
//  Created by Vit Chernuhin on 26.10.2023.
//  Copyright © 2023 Karmadust. All rights reserved.
//

import Foundation

public struct CalendarDay {
    let date: Date
    var isActive: Bool
}

extension CalendarDay: Equatable {
    public static func == (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        (lhs.date == rhs.date)
    }
}


