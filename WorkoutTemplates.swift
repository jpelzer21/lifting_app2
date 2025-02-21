//
//  WorkoutTemplate.swift
//  lift
//
//  Created by Josh Pelzer on 2/21/25.
//


import Foundation

struct WorkoutTemplates {
    static let templates: [String: [Exercise]] = [
        "Chest Day": [
            Exercise(name: "Bench Press", sets: [
                ExerciseSet(number: 1, weight: 135, reps: 10),
                ExerciseSet(number: 2, weight: 185, reps: 8),
                ExerciseSet(number: 3, weight: 185, reps: 8)
            ]),
            Exercise(name: "Incline Dumbbell Press", sets: [
                ExerciseSet(number: 1, weight: 50, reps: 10),
                ExerciseSet(number: 1, weight: 50, reps: 10),
                ExerciseSet(number: 1, weight: 50, reps: 10)
            ]),
            Exercise(name: "Tricep Extensions", sets: [
                ExerciseSet(number: 1, weight: 50, reps: 10),
                ExerciseSet(number: 1, weight: 50, reps: 10),
                ExerciseSet(number: 1, weight: 50, reps: 10)
            ]),
            Exercise(name: "Chest Fly", sets: [
                ExerciseSet(number: 1, weight: 30, reps: 12),
                ExerciseSet(number: 1, weight: 50, reps: 10),
                ExerciseSet(number: 1, weight: 50, reps: 10)
            ]),
            Exercise(name: "Shoulder Press", sets: [
                ExerciseSet(number: 1, weight: 45, reps: 10),
                ExerciseSet(number: 1, weight: 50, reps: 10),
                ExerciseSet(number: 1, weight: 50, reps: 10)
            ])
        ],
        "Leg Day": [
            Exercise(name: "Squats", sets: [
                ExerciseSet(number: 1, weight: 135, reps: 10),
                ExerciseSet(number: 2, weight: 225, reps: 8)
            ]),
            Exercise(name: "Leg Press", sets: [
                ExerciseSet(number: 1, weight: 200, reps: 12)
            ])
        ]
    ]
}
