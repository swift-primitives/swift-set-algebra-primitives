// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Algebra_Lattice_Primitives
public import Iterable

// MARK: - Powerset lattice grounding (∪ = join, ∩ = meet, ⊆ = order)
//
// Birkhoff: the powerset 𝒫(U) of a universe U, ordered by ⊆, is a bounded
// (and in fact distributive, complemented — i.e. Boolean) lattice with
// ∪ = join, ∩ = meet, ∅ = bottom, U = top. This packages that grounding as an
// `Algebra.Lattice` value built from the receiver's own `union` / `intersection`,
// so the set algebra is *general lattice theory* instantiated over a membership
// core, not prose (model §4.2 / §9).
//
// There is no separate Boolean-algebra witness type: `Swift.Bool` is the
// canonical Boolean algebra (`swift-bool-algebra-primitives`), and the powerset's
// relative complement is the package's own native operation —
// `universe.subtracting(A)` (∁A = U ∖ A).
//
// Defined as an extension ON `Set.Buildable.`Protocol`` (mirroring the
// constructive `union` / `intersection` ops), with `self` as the universe.

extension Set.Buildable.`Protocol`
where Self: Iterable & Copyable, Element: Copyable,
      Self.Iterator.Element == Element, Self.Iterator.Failure == Never {

    /// The **powerset lattice** with `self` as the universe (⊤): join = `union`
    /// (∪), meet = `intersection` (∩), bottom = ∅ (the empty set), top = `self`.
    ///
    /// The induced partial order (`Algebra.Lattice.leq`) is set inclusion ⊆
    /// (A ⊆ B ⟺ A ∪ B = B). The Boolean complement of a subset `A` relative to
    /// this universe is the native `self.subtracting(A)` (U ∖ A).
    ///
    /// - Returns: the bounded lattice whose join/meet are this set type's own
    ///   `union` / `intersection`, with `self` as the top element.
    @inlinable
    public func powerset() -> Algebra.Lattice<Self> where Self: Sendable {
        .init(
            bottom: Self(),
            join: { $0.union($1) },
            top: self,
            meet: { $0.intersection($1) }
        )
    }
}
