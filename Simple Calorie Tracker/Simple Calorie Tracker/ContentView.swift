//
//  ContentView.swift
//  Simple Calorie Tracker
//
//  Created by Benjamin Tia on 13/6/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var calorieCount = 0
    @State private var selectedIncrement = 1
    @State private var selectedDate = Date()
    @State private var monthlyCalories: [Date: Int] = [:]
    
    let increments = [1, 5, 10, 50, 100, 150, 200, 300, 400, 500, 1000]
    let calendar = Calendar.current
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // Function to get start of month for a date
    func startOfMonth(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    // Function to check if date is in current month
    func isInCurrentMonth(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
    }
    
    // Function to get calories for a specific date
    func getCaloriesForDate(_ date: Date) -> Int {
        if calendar.isDateInToday(date) {
            return calorieCount
        }
        return monthlyCalories[date] ?? 0
    }
    
    // Function to get days in current month
    func getDaysInMonth() -> [Date] {
        let start = startOfMonth(for: Date())
        let range = calendar.range(of: .day, in: .month, for: start)!
        return range.map { day in
            calendar.date(byAdding: .day, value: day - 1, to: start)!
        }
    }
    
    // Function to get first weekday of month (0 = Sunday, 6 = Saturday)
    func getFirstWeekday() -> Int {
        let start = startOfMonth(for: Date())
        return calendar.component(.weekday, from: start) - 1
    }
    
    // Function to get month name
    func getMonthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }
    
    // Function to check if date is today
    func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    // Function to save calories to UserDefaults
    func saveCalories() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var caloriesDict: [String: Int] = [:]
        for (date, calories) in monthlyCalories {
            let dateString = dateFormatter.string(from: date)
            caloriesDict[dateString] = calories
        }
        
        // Save current day's calories
        let todayString = dateFormatter.string(from: Date())
        caloriesDict[todayString] = calorieCount
        
        UserDefaults.standard.set(caloriesDict, forKey: "monthlyCalories")
    }
    
    // Function to load calories from UserDefaults
    func loadCalories() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let caloriesDict = UserDefaults.standard.dictionary(forKey: "monthlyCalories") as? [String: Int] {
            for (dateString, calories) in caloriesDict {
                if let date = dateFormatter.date(from: dateString) {
                    if calendar.isDateInToday(date) {
                        calorieCount = calories
                    } else {
                        monthlyCalories[date] = calories
                    }
                }
            }
        }
    }
    
    // Function to get total calories for current month
    func getTotalMonthlyCalories() -> Int {
        let start = startOfMonth(for: selectedDate)
        let range = calendar.range(of: .day, in: .month, for: start)!
        let days = range.map { day in
            calendar.date(byAdding: .day, value: day - 1, to: start)!
        }
        return days.reduce(0) { total, date in
            total + getCaloriesForDate(date)
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Simple Calorie Tracker")
                .font(.custom("Impact", size: 32))
                .fontWeight(.regular)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            VStack(spacing: 2) {
                Text("Calorie Increment")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, -5)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(increments, id: \.self) { increment in
                            Button(action: {
                                selectedIncrement = increment
                            }) {
                                Text("\(increment) cal")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedIncrement == increment ? Color.blue : Color.gray.opacity(0.2))
                                    )
                                    .foregroundColor(selectedIncrement == increment ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 50)
            }
            
            HStack(spacing: 40) {
                Button(action: {
                    if isInCurrentMonth(selectedDate) {
                        if calendar.isDateInToday(selectedDate) {
                            calorieCount = max(0, calorieCount - selectedIncrement)
                        } else {
                            let currentCalories = getCaloriesForDate(selectedDate)
                            monthlyCalories[selectedDate] = max(0, currentCalories - selectedIncrement)
                        }
                        saveCalories()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                }
                
                VStack(spacing: 5) {
                    Text("\(getCaloriesForDate(selectedDate))")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("calories")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    if isInCurrentMonth(selectedDate) {
                        if calendar.isDateInToday(selectedDate) {
                            calorieCount += selectedIncrement
                        } else {
                            let currentCalories = getCaloriesForDate(selectedDate)
                            monthlyCalories[selectedDate] = currentCalories + selectedIncrement
                        }
                        saveCalories()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                }
            }
            
            Button(action: {
                if isInCurrentMonth(selectedDate) {
                    if calendar.isDateInToday(selectedDate) {
                        calorieCount = 0
                    } else {
                        monthlyCalories[selectedDate] = 0
                    }
                    saveCalories()
                }
            }) {
                Text("Reset")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            // Custom Calendar View
            VStack(spacing: 8) {
                Text(getMonthName())
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
                
                // Days of week header
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar grid
                let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
                LazyVGrid(columns: columns, spacing: 8) {
                    // Empty spaces for days before the first of the month
                    ForEach(0..<getFirstWeekday(), id: \.self) { _ in
                        Color.clear
                            .frame(height: 35)
                    }
                    
                    // Days of the month
                    ForEach(getDaysInMonth(), id: \.self) { date in
                        let day = calendar.component(.day, from: date)
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let hasCalories = getCaloriesForDate(date) > 0
                        let isCurrentDay = isToday(date)
                        
                        Button(action: {
                            selectedDate = date
                        }) {
                            Text("\(day)")
                                .frame(height: 35)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Circle()
                                        .fill(isSelected ? Color.blue : (isCurrentDay ? Color.gray.opacity(0.3) : (hasCalories ? Color.blue.opacity(0.2) : Color.clear)))
                                )
                                .foregroundColor(isSelected ? .white : .primary)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Total monthly calories
            VStack(spacing: 5) {
                Text("Total calories consumed this month:")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("\(getTotalMonthlyCalories())")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadCalories()
        }
    }
}

#Preview {
    ContentView()
}


