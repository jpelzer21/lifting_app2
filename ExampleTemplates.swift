//
//  ExampleTemplates.swift
//  lift
//
//  Created by Josh Pelzer on 3/16/25.
//


//
//  ExampleTemplates.swift
//  lift
//
//  Created by Josh Pelzer on 3/15/25.
//

import Foundation

struct ExampleTemplates {
    static let templates: [WorkoutTemplate] = [
        WorkoutTemplate(
            id: "chest_day",
            name: "Chest Day",
            exercises: [
                Exercise(name: "Bench Press", sets: [
                    ExerciseSet(number: 1, weight: 135, reps: 10),
                    ExerciseSet(number: 2, weight: 155, reps: 8),
                    ExerciseSet(number: 3, weight: 175, reps: 6)
                ]),
                Exercise(name: "Incline Dumbbell Press", sets: [
                    ExerciseSet(number: 1, weight: 50, reps: 10),
                    ExerciseSet(number: 2, weight: 55, reps: 8)
                ]),
                Exercise(name: "Cable Flys", sets: [
                    ExerciseSet(number: 1, weight: 30, reps: 12),
                    ExerciseSet(number: 2, weight: 35, reps: 10)
                ])
            ]
        ),
        WorkoutTemplate(
            id: "back_day",
            name: "Back Day",
            exercises: [
                Exercise(name: "Pull-ups", sets: [
                    ExerciseSet(number: 1, weight: 0, reps: 10),
                    ExerciseSet(number: 2, weight: 0, reps: 8)
                ]),
                Exercise(name: "Deadlifts", sets: [
                    ExerciseSet(number: 1, weight: 185, reps: 8),
                    ExerciseSet(number: 2, weight: 225, reps: 6)
                ]),
                Exercise(name: "Bent-over Rows", sets: [
                    ExerciseSet(number: 1, weight: 95, reps: 12),
                    ExerciseSet(number: 2, weight: 115, reps: 10)
                ])
            ]
        ),
        WorkoutTemplate(
            id: "leg_day",
            name: "Leg Day",
            exercises: [
                Exercise(name: "Squats", sets: [
                    ExerciseSet(number: 1, weight: 135, reps: 10),
                    ExerciseSet(number: 2, weight: 185, reps: 8)
                ]),
                Exercise(name: "Leg Press", sets: [
                    ExerciseSet(number: 1, weight: 200, reps: 12),
                    ExerciseSet(number: 2, weight: 250, reps: 10)
                ]),
                Exercise(name: "Calf Raises", sets: [
                    ExerciseSet(number: 1, weight: 90, reps: 15),
                    ExerciseSet(number: 2, weight: 110, reps: 12)
                ])
            ]
        )
    ]
}
