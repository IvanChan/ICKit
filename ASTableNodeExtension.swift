//
//  ASTableNodeExtension.swift
//  ICKit
//
//  Created by _ivanc on 2019/12/22.
//

import UIKit
import AsyncDisplayKit

extension ASTableNode {
    func insertSectionsWithoutAnimation(at indexSet:IndexSet) {
        UIView.performWithoutAnimation {
            self.insertSections(indexSet, with: .none)
        }
    }
    func insertRowsWithoutAnimation(at indexPaths:[IndexPath]) {
        UIView.performWithoutAnimation {
            self.insertRows(at: indexPaths, with: .none)
        }
    }
    
    func deleteRowsWithoutAnimation(at indexPaths:[IndexPath]) {
        UIView.performWithoutAnimation {
            self.deleteRows(at: indexPaths, with: .none)
        }
    }
    
    func reloadRowsWitoutAnimation(at indexPaths:[IndexPath]) {
        UIView.performWithoutAnimation {
            self.reloadRows(at: indexPaths, with: .none)
        }
    }
    
    func reloadSectionsWitoutAnimation(_ sections:IndexSet) {
        UIView.performWithoutAnimation {
            self.reloadSections(sections, with: .none)
        }
    }
    
    func reloadDataWitoutAnimation() {
        UIView.performWithoutAnimation {
            self.reloadData()
        }
    }
}

extension ASCollectionNode {
    func insertItemsWithoutAnimation(at indexPaths:[IndexPath]) {
        UIView.performWithoutAnimation {
            self.insertItems(at: indexPaths)
        }
    }
    
    func deleteItemsWithoutAnimation(at indexPaths:[IndexPath]) {
        UIView.performWithoutAnimation {
            self.deleteItems(at: indexPaths)
        }
    }
    
    func reloadItemsWitoutAnimation(at indexPaths:[IndexPath]) {
        UIView.performWithoutAnimation {
            self.reloadItems(at: indexPaths)
        }
    }
    
    func reloadDataWitoutAnimation() {
        UIView.performWithoutAnimation {
            self.reloadData()
        }
    }
}
