//
//  Observable.swift
//  assignment
//
//  Created by 이지훈 on 5/27/24.
//

import Foundation

class ObservablePattern<T> {
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    private var listener: ((T) -> Void)?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping (T) -> Void) {
        self.listener = listener
        listener(value)
    }
}
