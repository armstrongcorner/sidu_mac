//
//  DatabaseProviderTests.swift
//  siduTests
//
//  Created by Armstrong Liu on 21/01/2025.
//

import XCTest
import SwiftData
@testable import sidu

final class DatabaseProviderTests: XCTestCase {
    var testContainer: ModelContainer!
    
    var sutUserHandler: UserHandler!
    var sutTopicHandler: TopicHandler!
    var sutChatHandler: ChatHandler!
    
    override func setUp() {
        super.setUp()
        
        testContainer = try? ContainerForTest.createTestContainer(databaseName: String(describing: Self.self))
        
        sutUserHandler = UserHandler(container: testContainer)
        sutTopicHandler = TopicHandler(container: testContainer)
        sutChatHandler = ChatHandler(container: testContainer)
    }
    
    override func tearDown() {
        testContainer = nil
        
        sutUserHandler = nil
        sutTopicHandler = nil
        sutChatHandler = nil
        
        super.tearDown()
    }
    
    func testAddUser() async throws {
        // when
        try await sutUserHandler.addUser(data: mockUserInfoModel1)
        let theResult = try await sutUserHandler.fetchUser(byUsername: mockUserInfoModel1.userName ?? "")
        
        // then
        XCTAssertNotNil(theResult, "The result user info should not be nil")
        XCTAssertEqual(theResult!.userName, mockUserInfoModel1.userName, "The result username should be equal to the input model username")
    }
    
    func testDeleteUser() async throws {
        // when
        try await sutUserHandler.deleteUser(byUsername: mockUserInfoModel1.userName ?? "")
        let theResult = try await sutUserHandler.fetchUser(byUsername: mockUserInfoModel1.userName ?? "")
        
        // then
        XCTAssertNil(theResult)
    }
    
    func testUpdateUser() async throws {
        // given
        let updateUserInfoModel = UserInfoModel(
            id: mockUserInfoModel1.id,
            userName: "UpdatedUserName",
            password: mockUserInfoModel1.password,
            photo: mockUserInfoModel1.photo,
            role: mockUserInfoModel1.role,
            mobile: mockUserInfoModel1.mobile,
            email: mockUserInfoModel1.email,
            serviceLevel: mockUserInfoModel1.serviceLevel,
            tokenDurationInMin: mockUserInfoModel1.tokenDurationInMin,
            isActive: mockUserInfoModel1.isActive,
            createdDateTime: mockUserInfoModel1.createdDateTime,
            updatedDateTime: mockUserInfoModel1.updatedDateTime,
            createdBy: mockUserInfoModel1.createdBy,
            updatedBy: mockUserInfoModel1.updatedBy
        )
        
        // when
        let theId = try await sutUserHandler.addUser(data: mockUserInfoModel1)
        let theResult = try await sutUserHandler.fetchUser(byUsername: mockUserInfoModel1.userName ?? "")
        
        // then
        XCTAssertNotNil(theResult, "The result user info should not be nil")
        XCTAssertEqual(theResult!.userName, mockUserInfoModel1.userName, "The result username should be equal to the input model username")
        
        // when
        try await sutUserHandler.updateUser(id: theId, data: updateUserInfoModel)
        let theUpdatedResult = try await sutUserHandler.fetchUser(byUsername: updateUserInfoModel.userName ?? "")
        
        // then
        XCTAssertEqual(theUpdatedResult!.userName, updateUserInfoModel.userName, "The result username should be updated")
        
        // when
        try await sutUserHandler.updateUser(id: theId, data: mockUserInfoModel1)
        let theOrigResult = try await sutUserHandler.fetchUser(byUsername: mockUserInfoModel1.userName ?? "")
        
        // then
        XCTAssertEqual(theOrigResult?.userName, mockUserInfoModel1.userName, "The result should be updated back to original mockUserInfoModel1")
    }
    
    func testAddTopic() async throws {
        // when
        try await sutUserHandler.addUser(data: mockUserInfoModel1)
        try await sutTopicHandler.addTopic(data: mockTopicMessage1, username: mockUserInfoModel1.userName ?? "")
        try await sutTopicHandler.addTopic(data: mockTopicMessage2, username: mockUserInfoModel1.userName ?? "")
        
        // then
        let topics: [TopicMessage] = try await sutTopicHandler.fetchTopics(byUsername: mockUserInfoModel1.userName ?? "")
        XCTAssertEqual(topics.count, 2, "There should be 2 new added topics to mockUser1 ")
        
        if let firstTopic = topics.first {
            XCTAssertEqual(firstTopic.title, mockTopicMessage1.title, "The first topic name should be \(mockTopicMessage1.title ?? "")")
        } else {
            XCTFail("There should be at least one topic")
        }
    }
    
    func testDeleteTopic() async throws {
        // given
        try await sutUserHandler.addUser(data: mockUserInfoModel1)
        try await sutTopicHandler.addTopic(data: mockTopicMessage1, username: mockUserInfoModel1.userName ?? "")
        try await sutTopicHandler.addTopic(data: mockTopicMessage2, username: mockUserInfoModel1.userName ?? "")
        try await sutTopicHandler.addTopic(data: mockTopicMessage3, username: mockUserInfoModel1.userName ?? "")
        
        // when
        try await sutTopicHandler.deleteTopic(topicId: mockTopicMessage3.id ?? "")
        
        // then
        let topics: [TopicMessage] = try await sutTopicHandler.fetchTopics(byUsername: mockUserInfoModel1.userName ?? "")
        XCTAssertEqual(topics.count, 2, "There should be 2 topics left after deleting one")
        XCTAssertEqual(topics.last?.title, mockTopicMessage2.title, "The last topic should be \(mockTopicMessage2.title ?? "")")
        
        // when
        try await sutTopicHandler.deleteTopic(byUsername: mockUserInfoModel1.userName ?? "")
        
        // then
        let topicsLeft: [TopicMessage] = try await sutTopicHandler.fetchTopics(byUsername: mockUserInfoModel1.userName ?? "")
        XCTAssertEqual(topicsLeft.count, 0, "There should be no topics left for account \(mockUserInfoModel1.userName ?? "") after deleting all")
    }
    
    func testDeleteTopicFromDeleteUser() async throws {
        // given
        try await sutUserHandler.addUser(data: mockUserInfoModel1)
        try await sutTopicHandler.addTopic(data: mockTopicMessage1, username: mockUserInfoModel1.userName ?? "")
        try await sutTopicHandler.addTopic(data: mockTopicMessage2, username: mockUserInfoModel1.userName ?? "")
        
        // when
        try await sutUserHandler.deleteUser(byUsername: mockUserInfoModel1.userName ?? "")
        let topicsLeft: [TopicMessage] = try await sutTopicHandler.fetchTopics(byUsername: mockUserInfoModel1.userName ?? "")
        
        // then
        XCTAssertEqual(topicsLeft.count, 0, "There should be no topics left after deleting mockUser1")
    }
    
    func testUpdateTopic() async throws {
        // given
        let updateTopicMessage = TopicMessage(
            id: mockTopicMessage1.id,
            title: "Updated Topic Name",
            createTime: mockTopicMessage1.createTime,
            isComplete: mockTopicMessage1.isComplete
        )
        try await sutUserHandler.addUser(data: mockUserInfoModel1)
        try await sutTopicHandler.addTopic(data: mockTopicMessage1, username: mockUserInfoModel1.userName ?? "")
        
        // when
        try await sutTopicHandler.updateTopic(topicId: mockTopicMessage1.id ?? "", data: updateTopicMessage)
        
        // then
        let topics: [TopicMessage] = try await sutTopicHandler.fetchTopics(byUsername: mockUserInfoModel1.userName ?? "")
        XCTAssertEqual(topics.count, 1, "There should be 1 topic only")
        XCTAssertEqual(topics.first?.title, updateTopicMessage.title, "The first topic name should be updated")
    }
}
