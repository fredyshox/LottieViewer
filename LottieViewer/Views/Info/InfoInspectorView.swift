//
//  InfoInspectorView.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 24/04/2022.
//

import AppKit
import Combine

final class InfoInspectorView: NSView {
    let viewModel: InfoInspectorViewModel
    
    private let titleLabel = NSTextField()
    private let gridView = NSGridView()
    
    private var cancellableSet = Set<AnyCancellable>()
    
    init(viewModel: InfoInspectorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setup()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        viewModel.$cells
            .sink { [weak self] cells in
                self?.updateRows(with: cells)
            }
            .store(in: &cancellableSet)
    }
    
    private func setup() {
        gridView.rowAlignment = .firstBaseline
        
        makeLayout()
    }
    
    private func makeLayout() {
        addSubview(gridView)
        
        gridView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview().inset(12.0)
            make.top.equalToSuperview().inset(24.0)
        }
    }
    
    private func updateRows(with cells: [(InfoInspectorViewModel.Cells, String)]) {
        let rows: [[NSView]] = cells.map { (cell, content) in
            let titleLabel = NSTextField()
            titleLabel.isEditable = false
            titleLabel.isBezeled = false
            titleLabel.textColor = .secondaryLabelColor
            titleLabel.backgroundColor = .clear
            titleLabel.stringValue = cell.localizedTitle
            
            let valueLabel = NSTextField()
            valueLabel.isEditable = false
            valueLabel.isBezeled = false
            valueLabel.textColor = .labelColor
            valueLabel.backgroundColor = .clear
            valueLabel.stringValue = content
            
            return [titleLabel, valueLabel]
        }
        
        gridView.removeAllRows()
        rows.forEach { views in
            gridView.addRow(with: views)
        }
        gridView.column(at: 0).xPlacement = .trailing
        gridView.column(at: 1).xPlacement = .leading
    }
}

extension NSGridView {
    func removeAllRows() {
        (0..<numberOfRows).forEach { index in
            removeRow(at: index)
        }
    }
}
