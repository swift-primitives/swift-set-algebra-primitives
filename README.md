# Set Algebra Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The orthogonal **set algebra** — relational predicates (`isSubset`, `isSuperset`, `isDisjoint`, `isStrictSubset`, `isStrictSuperset`, `isEqual`) and constructive operations (`union`, `intersection`, `subtracting`, `symmetricDifference`) — supplied as protocol-extension defaults over the membership core in `swift-set-primitives`.

---

## Quick Start

Algebra is a *third orthogonal concern*, composed over the set membership core (`Set.Protocol` = `{contains, count}`) and the iteration concern (`Iterable`) — never baked into either. Any type that conforms `Set.Protocol & Iterable` inherits the relational predicates for free; any growable `Set.Buildable.Protocol & Iterable` additionally inherits the `Self`-returning constructive operations.

```swift
import Set_Algebra_Primitives

// Predicates work over any two conformers with the same element — even
// different set types — against borrowed receivers, with no allocation:
func overlap<A: Set.`Protocol` & Iterable, B: Set.`Protocol` & Iterable>(
    _ a: borrowing A, _ b: borrowing B
) -> Bool where A.Element == B.Element, A.Element: Copyable,
                A.Iterator.Element == A.Element, B.Iterator.Element == B.Element {
    !a.isDisjoint(with: b)
}
```

Constructive operations return `Self` (on the growable `Set.Buildable.Protocol` refinement), so a set discipline gets back its own type:

```swift
let u = a.union(b)          // Self
let i = a.intersection(b)   // Self
```

## Architecture

This package bridges the membership core (`swift-set-primitives`) with the iteration concern (`swift-iterator-primitives`), carrying only the element-wise algebra:

- **Predicates** — `where Self: Set.Protocol & Iterable` (the Copyable-element slice).
- **Constructive** — `where Self: Set.Buildable.Protocol & Iterable`, returning `Self`.

The `@inlinable` defaults monomorphize to **0 `witness_method`** on the hot path in release, cross-package. The formal lattice/Boolean grounding of these operations (∪ = join, ∩ = meet, …) is a separate, deferred concern.

## License

Apache License 2.0. See [LICENSE.md](LICENSE.md).
