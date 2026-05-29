# ``Set_Algebra_Primitives``

The orthogonal **set algebra** — relational predicates and constructive operations — composed over the membership core as protocol-extension defaults.

## Overview

`Set.Protocol` is the minimal membership core (`contains` + `count`). The set *algebra* is a third orthogonal concern, composed over the core and the iteration concern (``Iterable``) rather than baked into either:

- **Relational predicates** (`isDisjoint`, `isSubset`, `isSuperset`, `isStrictSubset`, `isStrictSuperset`, `isEqual`) attach `where Self: Set.Protocol & Iterable`. They enumerate via the iteration concern and probe via the membership core, so they work across *any* two conformers with the same element — even different set types.
- **Constructive operations** (`union`, `intersection`, `subtracting`, `symmetricDifference`) attach `where Self: Set.Buildable.Protocol & Iterable` and return **`Self`** — total only on growable sets (hence the `Set.Buildable.Protocol` refinement).

All defaults are `@inlinable` and monomorphize to **0 `witness_method`** on the hot path in release, cross-package.

This package is an extraction bridge between `swift-set-primitives` (the membership core + the growable refinement) and `swift-iterator-primitives` (the iteration concern). The formal lattice/Boolean grounding of these operations (∪ = join, ∩ = meet, ∁ = complement) is a separate, deferred concern.

## Topics

### Relational predicates

Composed `where Self: Set.Protocol & Iterable` — see ``Set/Protocol``.

### Constructive operations

Composed `where Self: Set.Buildable.Protocol & Iterable`, returning `Self`.
