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

// Set Algebra Primitives owns the orthogonal set *algebra* — the relational
// predicates (`where Self: Set.Protocol & Iterable`) and the constructive ops
// (`where Self: Set.Protocol & Buildable & Iterable`, returning `Self`). It is
// the lone set-primitives sibling that depends on the iteration concern
// (`Iterable`); the membership core stays iteration-free. Re-exports the
// membership core + builder-primitives' `Buildable` + `Iterable` so the algebra
// surface is self-contained — there is no bundled `Set.Buildable.Protocol`; the
// buildable concern is builder-primitives × set-primitives, composed here.

// The formal algebra grounding (model §4.2 / §9): the powerset lattice witness
// (`someUniverse.powerset() -> Algebra.Lattice`) lives here, so re-export the
// lattice structure it produces.
@_exported public import Algebra_Lattice_Primitives
@_exported public import Builder_Primitives
@_exported public import Iterable
@_exported public import Set_Protocol_Primitives
