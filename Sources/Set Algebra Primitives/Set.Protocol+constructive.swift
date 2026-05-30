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

public import Set_Protocol_Primitives
public import Builder_Primitives
public import Iterable

// MARK: - Constructive Algebra (returns `Self`, composed over Set.Protocol × builder's Buildable)
//
// The constructive operations build a new set, so they are total only on
// growable sets — hence `Self: Buildable` (builder-primitives' generic build
// capability: `Initiable`'s `init()` + the neutral `add`). They return **`Self`**
// (the model §4.2 result-type fix), not a hard-coded `Set.Ordered`, so each
// growable discipline gets back its own type and needs no downstream home.
// Bounded disciplines (`Set.Ordered.Fixed`/`.Static`) are NOT `Buildable`
// and inherit the predicates only — a `Self`-returning constructive op on a
// bounded set could silently overflow.
//
// There is no bundled `Set.Buildable.Protocol`: the buildable concern is
// builder-primitives × set-primitives, composed here as `Set.Protocol &
// Buildable`. The result is filled through `add` (builder's neutral grow op),
// which each set conforms by delegating to its own `insert` and discarding the
// report.
//
// `Self.Failure == Never`: empty construction (`Self()`) is infallible for every
// growable set, so the constructive ops are non-throwing. `Element: Copyable` is
// required: these ops copy elements into the result.

extension Set.`Protocol`
where Self: Buildable & Iterable & ~Copyable, Element: Copyable, Self.Failure == Never,
      Self.Iterator.Element == Element, Self.Iterator.Failure == Never {

    /// Returns a new set with elements from both sets.
    ///
    /// Elements from `self` appear first in iteration order, followed by
    /// elements from `other` not already present.
    ///
    /// - Parameter other: The set to form a union with.
    /// - Returns: A new set containing all elements from both sets.
    /// - Complexity: O(n + m) average, where n and m are the set sizes.
    @inlinable
    public func union<Other: Set.`Protocol` & Iterable & ~Copyable>(
        _ other: borrowing Other
    ) -> Self
    where Other.Element == Element, Other.Iterator.Element == Element, Other.Iterator.Failure == Never {
        var result = Self()
        self.forEach { element in result.add(copy element) }
        other.forEach { element in result.add(copy element) }
        return result
    }

    /// Returns a new set with elements common to both sets.
    ///
    /// Iterates `self` (the receiver) and probes `other`, so the result
    /// preserves the receiver's iteration order — the deterministic
    /// intersection contract (consistent with `union` / `subtracting` /
    /// `symmetricDifference`, which are all receiver-first). A smaller-set
    /// optimization would be order-nondeterministic and is intentionally not used.
    ///
    /// - Parameter other: The set to intersect with.
    /// - Returns: A new set containing only elements present in both sets,
    ///   in the receiver's order.
    /// - Complexity: O(n) average, where n is the size of the receiver.
    @inlinable
    public func intersection<Other: Set.`Protocol` & Iterable & ~Copyable>(
        _ other: borrowing Other
    ) -> Self
    where Other.Element == Element, Other.Iterator.Element == Element, Other.Iterator.Failure == Never {
        var result = Self()
        self.forEach { element in
            if other.contains(element) { result.add(copy element) }
        }
        return result
    }

    /// Returns a new set with the elements of this set that are not in `other`.
    ///
    /// Elements appear in the iteration order of `self`. Non-mutating — the
    /// mutating counterpart would be `subtract`; this is `subtracting` per the
    /// Swift API guidelines / `SetAlgebra` precedent.
    ///
    /// - Parameter other: The set to subtract.
    /// - Returns: A new set with elements not in `other`.
    /// - Complexity: O(n) average, where n is the size of this set.
    @inlinable
    public func subtracting<Other: Set.`Protocol` & Iterable & ~Copyable>(
        _ other: borrowing Other
    ) -> Self
    where Other.Element == Element, Other.Iterator.Element == Element, Other.Iterator.Failure == Never {
        var result = Self()
        self.forEach { element in
            if !other.contains(element) { result.add(copy element) }
        }
        return result
    }

    /// Returns a new set with elements in either set, but not both.
    ///
    /// Elements from `self` (absent from `other`) appear first, followed by
    /// elements from `other` absent from `self`.
    ///
    /// - Parameter other: The other set.
    /// - Returns: A new set with elements in exactly one of the sets.
    /// - Complexity: O(n + m) average, where n and m are the set sizes.
    @inlinable
    public func symmetricDifference<Other: Set.`Protocol` & Iterable & ~Copyable>(
        _ other: borrowing Other
    ) -> Self
    where Other.Element == Element, Other.Iterator.Element == Element, Other.Iterator.Failure == Never {
        var result = Self()
        self.forEach { element in
            if !other.contains(element) { result.add(copy element) }
        }
        other.forEach { element in
            if !self.contains(element) { result.add(copy element) }
        }
        return result
    }
}
