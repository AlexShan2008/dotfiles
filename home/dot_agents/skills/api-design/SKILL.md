---
name: api-design
description: Design or review programming interfaces at any boundary, including functions, types, modules, components, libraries, CLIs, services, schemas, and generated artifacts. Use when choosing signatures, data shapes, naming, ownership, errors, compatibility, validation, or migration strategy.
---

# API Design Principles

Treat every interface between a caller and an implementation as an API. The caller may be another expression, function, module, package, process, service, tool, or team.

Apply the principles at every scope, but scale the ceremony to the cost of misuse and change. A private helper does not need the compatibility process of a published library, yet both benefit from a clear and unsurprising contract.

## Core Objectives

1. Make the correct path obvious and misuse difficult.
2. Minimize caller effort and unnecessary choices.
3. Follow established conventions so the interface remains predictable, extensible, and maintainable.

## Design Principles

- **Start with caller intent.** Model what callers need to accomplish, not how the implementation happens to work. Expose the smallest coherent contract that supports those tasks.
- **Make invalid usage difficult.** Use signatures, types, states, defaults, and validation that guide callers toward correct behavior. Do not rely on documentation when the interface can express the constraint directly.
- **Provide one canonical path per concept.** Avoid equivalent functions, flags, entry points, aliases, or data shapes that force arbitrary choices. Multiple paths are justified only when they represent meaningfully different semantics or environments.
- **Keep abstraction levels consistent.** An interface should not mix high-level intent with low-level implementation controls unless callers genuinely need both. Separate advanced control into a clearly distinct layer.
- **Keep implementation details private.** Callers should not depend on internal names, storage formats, generators, module boundaries, or incidental sequencing.
- **Put adaptation at the owning boundary.** The implementation that owns the data or behavior should also own normalization and mapping into the caller-facing contract. Do not make every caller reproduce the same translation logic.
- **Make names match semantics.** Names should describe the exact behavior, content, units, and side effects they expose. Related operations and representations should use a consistent vocabulary.
- **Define behavior, not only shape.** Make errors, nullability, mutability, ordering, idempotency, lifecycle, side effects, and resource ownership explicit wherever they affect correct use.
- **Prefer ecosystem conventions.** Follow the target language, framework, protocol, and domain conventions when they satisfy the requirement. Introduce a new abstraction only when it removes a real limitation.
- **Use types as executable documentation.** Prefer precise types, useful completion, and source-derived documentation over contracts that depend on prose or caller discipline.
- **Design for proportionate evolution.** The wider and less coordinated the caller base, the stronger the compatibility guarantees should be. For stable APIs, define deprecation, versioning, and migration paths before breaking callers; for local APIs, refactor freely when all callers can be updated safely.
- **Guard contracts against drift.** Generate repeated representations from canonical sources where practical, and test meaningful invariants at the boundary rather than maintaining duplicated literals by hand.
- **Keep examples executable.** Verify documented calls, imports, requests, and integration snippets with tests or smoke checks appropriate to the interface.

## Review Checklist

- [ ] The interface is organized around caller tasks rather than internal structure.
- [ ] Correct usage is obvious, and invalid or ambiguous usage is difficult.
- [ ] Each concept has one canonical operation or representation.
- [ ] The abstraction level is consistent, with advanced control separated when needed.
- [ ] Internal names and representations do not leak across the boundary.
- [ ] Normalization and mapping are owned by the implementation rather than duplicated by callers.
- [ ] Names, types, errors, side effects, and lifecycle rules communicate the complete contract.
- [ ] The interface follows relevant language and ecosystem conventions.
- [ ] Compatibility and migration guarantees match the size and coordination cost of the caller base.
- [ ] Tests and executable examples cover the most important contract invariants.

## Examples Across Scopes

- **Function:** Prefer a signature that makes required state and units explicit over a collection of loosely related booleans or primitive values.
- **Module or library:** Export one canonical representation for each concept and keep internal helpers private. Avoid default and named aliases for the same value unless the ecosystem clearly expects both.
- **Service or schema:** Keep wire formats stable, define error semantics, and version breaking changes according to consumer coordination cost.
- **CLI:** Use predictable verbs, flags, exit codes, and output contracts; separate human-readable output from machine-readable output when both are supported.
- **Generated API:** Generate types, documentation, and serialized forms from one canonical source, then validate that they remain structurally consistent.

## Design Token Example

For a design-token API:

- Keep raw tokens, semantic tokens, and theme slots as distinct layers.
- Let consumer components use ecosystem-standard slots such as `--primary` and `--background`; keep internal names such as `--shan-*` behind the mapping layer.
- Use accurate, symmetrical names such as `tokens.js`, `tokens.json`, and `tokens.css` when those files represent the same token family in different formats.
- Prefer established interchange and theming conventions, such as DTCG JSON and the current shadcn/Tailwind slot model, when they fit the target ecosystem.
- Generate literal types and JSDoc from canonical token metadata, then validate that generated exports and CSS contain no hand-maintained values that can drift.

## References

- Local example, if available: `~/Desktop/codes/alex/brand`, including its layered CSS, canonical token data, and generated interfaces.
- External benchmarks: current Shopify Polaris token packaging and current shadcn/Tailwind theming conventions. Verify upstream behavior before adopting implementation details.
