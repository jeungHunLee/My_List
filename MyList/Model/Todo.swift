//
//  Model.swift
//  Snail_ToDo
//
//  Created by 이정훈 on 2023/01/16.
//

import Foundation

struct Todo: Hashable, Identifiable {    //ForEach를 위해 Hashable protocol 준수
    var title: String          //할일 제목
    var description: String    //메모
    var complete: Bool         //완료 여부
    var date: Date             //날짜
    var id: UUID               //swift에서 제공하는 identifiable한 id
}

var todoList: [Todo] = [firstTodo, secondTodo]   //할일 목록
