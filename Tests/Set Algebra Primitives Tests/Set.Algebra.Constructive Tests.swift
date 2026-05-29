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

import Set_Algebra_Primitives_Test_Support
import Testing

// Constructive set algebra (`union` / `intersection` / `subtracting` /
// `symmetricDifference`) + the `powerset()` lattice grounding, exercised against
// `Set.Fixture` — the package's own buildable (`Set.Buildable.`Protocol``)
// conformer. These witnesses are set-algebra's own surface, so they are tested
// here, NOT in any storage-discipline package (set-ordered etc.): the discipline
// packages depend on neither set-algebra nor each other; a consumer that wants
// algebra over a concrete set composes both at the import site.

// MARK: - Helper

private func toArray<S: Iterable & ~Copyable>(_ set: borrowing S) -> [S.Iterator.Element]
where S.Iterator.Element: Hashable, S.Iterator.Failure == Never {
    var result: [S.Iterator.Element] = []
    set.forEach { result.append($0) }
    return result
}

private func fixture(_ elements: [Int]) -> Set<Int>.Fixture {
    var set = Set<Int>.Fixture()
    for element in elements { set.insert(element) }
    return set
}

// MARK: - Constructive Algebra

@Suite("Set Algebra — Constructive")
struct ConstructiveAlgebraTests {

    @Test
    func `union contains elements of both, receiver-first`() {
        let a = fixture([1, 2, 3])
        let b = fixture([3, 4, 5])
        #expect(toArray(a.union(b)) == [1, 2, 3, 4, 5])
    }

    @Test
    func `intersection contains common elements, receiver order`() {
        let a = fixture([1, 2, 3, 4])
        let b = fixture([2, 4, 6])
        #expect(toArray(a.intersection(b)) == [2, 4])
    }

    @Test
    func `subtracting removes elements present in other`() {
        let a = fixture([1, 2, 3, 4, 5])
        let b = fixture([2, 4])
        #expect(toArray(a.subtracting(b)) == [1, 3, 5])
    }

    @Test
    func `symmetric difference contains elements in exactly one`() {
        let a = fixture([1, 2, 3])
        let b = fixture([2, 3, 4])
        #expect(toArray(a.symmetricDifference(b)) == [1, 4])
    }
}

// MARK: - Powerset Lattice
//
// Birkhoff: the powerset 𝒫(U) ordered by ⊆ is a bounded lattice with ∪ = join,
// ∩ = meet, ∅ = bottom, U = top. Set-algebra laws are compared order-insensitively
// (sort first): `Set.Fixture` iteration is insertion-ordered, and the join of two
// disjoint sets preserves insertion order, which need not match the universe's.

@Suite("Set Algebra — Powerset Lattice")
struct PowersetLatticeTests {

    @Test
    func `join is union, meet is intersection`() {
        let universe = fixture([1, 2, 3, 4])
        let lattice = universe.powerset()
        let a = fixture([1, 2])
        let b = fixture([2, 3])
        #expect(toArray(lattice.join(a, b)).sorted() == toArray(a.union(b)).sorted())
        #expect(toArray(lattice.meet(a, b)).sorted() == toArray(a.intersection(b)).sorted())
        #expect(toArray(lattice.join(a, b)).sorted() == [1, 2, 3])
        #expect(toArray(lattice.meet(a, b)) == [2])
    }

    @Test
    func `bottom is empty, top is the universe`() {
        let universe = fixture([1, 2, 3])
        let lattice = universe.powerset()
        #expect(toArray(lattice.bottom).isEmpty)
        #expect(toArray(lattice.top) == [1, 2, 3])
    }

    @Test
    func `inclusion: a subset of b iff a join b equals b`() {
        let universe = fixture([1, 2, 3, 4])
        let lattice = universe.powerset()
        let a = fixture([1, 2])
        let b = fixture([1, 2, 3])
        #expect(toArray(lattice.join(a, b)).sorted() == toArray(b).sorted())
        #expect(toArray(lattice.join(b, a)).sorted() != toArray(a).sorted())
    }

    @Test
    func `complement laws via native subtracting`() {
        let universe = fixture([1, 2, 3, 4])
        let lattice = universe.powerset()
        let a = fixture([1, 3])
        let notA = universe.subtracting(a)              // U ∖ A = {2, 4}
        #expect(toArray(notA) == [2, 4])
        // a ∨ ¬a = ⊤ (universe);  a ∧ ¬a = ⊥ (∅) — set-algebra laws, order-insensitive.
        #expect(toArray(lattice.join(a, notA)).sorted() == toArray(universe).sorted())
        #expect(toArray(lattice.meet(a, notA)).isEmpty)
    }
}
