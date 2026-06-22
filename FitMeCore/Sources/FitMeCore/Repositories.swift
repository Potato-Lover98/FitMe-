import Foundation

public protocol ReadingRepository: Sendable {
    func readings(for vital: VitalType, limit: Int) async -> [Reading]
    func add(_ reading: Reading) async
    func delete(_ id: UUID) async
}

public protocol UserRepository: Sendable {
    func currentUser() async -> User?
    func save(_ user: User) async
}

public protocol GoalRepository: Sendable {
    func goals() async -> [Goal]
    func save(_ goal: Goal) async
    func delete(_ id: UUID) async
}