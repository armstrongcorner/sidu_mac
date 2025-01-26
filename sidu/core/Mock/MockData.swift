//
//  MockData.swift
//  sidu
//
//  Created by Armstrong Liu on 22/01/2025.
//

import Foundation

let mockUserInfoModel1: UserInfoModel = UserInfoModel(
    id: 1,
    userName: "test user",
    password: "",
    photo: "",
    role: "User",
    mobile: "111",
    email: "test@test.com",
    serviceLevel: 1,
    tokenDurationInMin: 100,
    isActive: true,
    createdDateTime: "2025-01-01T00:00:00Z",
    updatedDateTime: "2025-01-01T00:00:00Z",
    createdBy: "test@test.com",
    updatedBy: "test@test.com"
)

let mockUserInfoModel2: UserInfoModel = UserInfoModel(
    id: 2,
    userName: "test user 2",
    password: "123",
    photo: "photo",
    role: "User",
    mobile: "222",
    email: "test2@test.com",
    serviceLevel: 1,
    tokenDurationInMin: 200,
    isActive: true,
    createdDateTime: "2025-01-01T00:00:00Z",
    updatedDateTime: "2025-01-01T00:00:00Z",
    createdBy: "test2@test.com",
    updatedBy: "test2@test.com"
)

let mockTopicMessage1: TopicMessage = TopicMessage(
    id: "1",
    title: "test topic 1",
    createTime: 1609459200,
    isComplete: true,
    chatMessages: []
)

let mockTopicMessage2: TopicMessage = TopicMessage(
    id: "2",
    title: "test topic 2",
    createTime: 1609459200,
    isComplete: false,
    chatMessages: []
)

let mockTopicMessage3: TopicMessage = TopicMessage(
    id: "3",
    title: "test topic 3",
    createTime: 1609459200,
    isComplete: false,
    chatMessages: []
)

let mockChatMessage1: ChatMessage = ChatMessage(
    id: "1",
    role: .user,
    content: "question 1",
    type: .text,
    createAt: 1609459200,
    status: .done
)

let mockChatMessage2: ChatMessage = ChatMessage(
    id: "2",
    role: .assistant,
    content: "answer 1",
    createAt: 1609459200,
    status: .done
)

let mockChatMessage3: ChatMessage = ChatMessage(
    id: "3",
    role: .user,
    content: "question 2",
    type: .text,
    createAt: 1609459200,
    status: .done
)

let mockChatMessage4: ChatMessage = ChatMessage(
    id: "4",
    role: .assistant,
    content: "answer 2",
    createAt: 1609459200,
    status: .done
)

let mockChatMessage5: ChatMessage = ChatMessage(
    id: "5",
    role: .user,
    content: "question 3",
    type: .text,
    createAt: 1609459200,
    status: .done
)

let mockChatMessage6: ChatMessage = ChatMessage(
    id: "6",
    role: .assistant,
    content: "answer 3",
    createAt: 1609459200,
    status: .done
)

let mockChatMessage7: ChatMessage = ChatMessage(
    id: "7",
    role: .user,
    content: "question 4",
    type: .text,
    createAt: 1609459200,
    status: .done
)

let mockChatMessage8: ChatMessage = ChatMessage(
    id: "8",
    role: .assistant,
    content: "answer 4",
    createAt: 1609459200,
    status: .done
)

let mockChatMessage9: ChatMessage = ChatMessage(
    id: "9",
    role: .user,
    content: "question 5",
    type: .text,
    createAt: 1609459200,
    status: .done
)

let mockChatMessage10: ChatMessage = ChatMessage(
    id: "10",
    role: .assistant,
    content: "answer 5",
    createAt: 1609459200,
    status: .done
)
