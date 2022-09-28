//
//  Combine+Extensions.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 27/09/2022.
//

import Combine

extension Publisher where Failure == Never {
  /**
  Assign operator on weak reference.
  */
  func assignNoRetain<Root: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<Root, Output>,
    on object: Root
  ) -> AnyCancellable {
    sink { [weak object] value in
      object?[keyPath: keyPath] = value
    }
  }
}
