//
//  TodoList.swift
//
//  Created by 이정훈 on 2023/01/16.
//

import SwiftUI

enum KeyBoard {
    case on, off
}

enum Sorting: String, CaseIterable {
    case add_date = "추가한 날짜"
    case importance = "중요도"
    case end_date = "종료시간"
    case completed = "완료된 항목"
}

struct TodoList: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showNew: Bool = false
    @FocusState var keyboard: KeyBoard?   //text field에 focuse를 주기 위한 속성
    @State private var showDetail: Bool = false
    @AppStorage("sorting") private var seletedSort: Sorting = .add_date
    
    var sortedTodoList: [Todo] {
        switch seletedSort {
        case .add_date:
            return modelData.todoList.sorted(by: { $0.addDate < $1.addDate })
        case .importance:
            return modelData.todoList.filter { $0.isImportant }
        case .end_date:
            return modelData.todoList.filter{ $0.showDate }.sorted(by: { $0.endDate < $1.endDate }) + modelData.todoList.filter{ !$0.showDate }
        case .completed:
            return modelData.todoList.filter { $0.completed }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("\(seletedSort.rawValue) 순", content: {
                    ForEach(sortedTodoList) { todo in
                        ZStack {
                            //navigation link
                            //to remove arrow, overlay the HStack over the navigationlink label
                            NavigationLink(destination: TodoDetail(showDetail: $showDetail, todo: todo), label: {})
                                .opacity(0.0)    //투명도
                            ListRow(todo: todo)
                        }
                    }
                    .onDelete(perform: removeRows)    //remove row when slide a row
                    .listRowSeparator(.hidden)    //헹 분리 선 숨김
                    .listRowBackground(    //row design
                        RoundedRectangle(cornerRadius: 10)
                            .shadow(color: .black, radius: 0.6, x: 4, y: 3)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(
                                top: 2,
                                leading: 5,
                                bottom: 5,
                                trailing: 5
                            )
                        )
                    )
                })
            }
            .listStyle(DefaultListStyle())
            .navigationBarTitle ("Todo List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("정렬", selection: $seletedSort) {
                            /*ForEach(Sorting.allCases, id: \.self) {
                                Text($0.rawValue)
                            }*/
                            HStack {
                                Image(systemName: "calendar")
                                Text(Sorting.add_date.rawValue)
                            }
                            .tag(Sorting.add_date)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                Text(Sorting.importance.rawValue)
                            }
                            .tag(Sorting.importance)
                            
                            HStack {
                                Image(systemName: "timer")
                                Text(Sorting.end_date.rawValue)
                            }
                            .tag(Sorting.end_date)
                            HStack {
                                Image(systemName: "checklist.checked")
                                Text(Sorting.completed.rawValue)
                            }
                            .tag(Sorting.completed)
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("새로운 Todo 추가") {
                        showNew.toggle()
                    }
                    .sheet(isPresented: $showNew, content: {
                        NewTodo(showNew: $showNew)
                            .onAppear {
                                self.keyboard = .on//view가 생성될때 isFocused 값 변경
                            }
                            .focused($keyboard, equals: .on)    //isFocused의 값이 .title과 같아지면 textfield focus
                    })
                    .buttonStyle(AddButtonStyle())
                }
            }
            .background(
                Color(red: 247 / 255, green: 247 / 255, blue: 245 / 255)
            )
            .scrollContentBackground(.hidden)    //list default background remove
        }
    }
    
    func removeRows(at offsets: IndexSet) -> Void {
        for i in offsets {
            for j in 0..<modelData.todoList.count {
                if sortedTodoList[i] == modelData.todoList[j] {
                    modelData.todoList.remove(at: j)
                    break
                }
            }
        }
    }
    
    func today(_ date: Date) -> String {    //나중에 title 옆에 현재 날짜를 표시하기 위한 format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 EE"
        
        return formatter.string(from: date)
    }
}



struct TodoList_Previews: PreviewProvider {
    static var previews: some View {
        TodoList()
            .environmentObject(ModelData())
    }
}
