# English AI-Pattern Catalog

Fast English/mixed-track rules. Meaning invariance overrides every recipe: do not add or remove facts, citations, actors, stance, modality, degree, sequence, examples, or recommendations. Protected quotes, numbers, proper nouns, code, and standard acronyms stay byte-for-byte unchanged. Leave a finding unresolved when no faithful rewrite exists.

### E1. Importance inflation [P1]

**Signals:** pivotal, crucial, vital, testament, reminder, setting the stage, turning point, indelible mark.

**Rule:** Reduce repeated unsupported framing while preserving any importance claim and every underlying fact.

### E2. Media/notability display [P1]

**Signals:** independent coverage, leading expert, active social media presence.

**Rule:** Preserve every outlet, citation, count, and notability claim; only simplify surrounding syntax.

### E3. Analytical `-ing` chains [P1]

**Signals:** highlighting, underscoring, ensuring, reflecting, symbolizing, contributing, fostering, showcasing.

**Rule:** Recast the same propositions without adding explanations, sources, or examples.

### E4. Promotional language [P1]

**Signals:** vibrant, profound, groundbreaking, breathtaking, robust, seamless, cutting-edge, game-changing.

**Rule:** Reduce repeated promotional modifiers only when degree and stance remain unchanged. Never replace them with invented concrete facts.

### E5. Vague sources / weasel words [P1]

**Signals:** experts argue, observers say, industry reports, several sources.

**Rule:** Do not invent a source. Preserve the attribution or leave the finding unresolved unless the source already appears in the input.

### E6. “Challenges and future prospects” formula [P1]

**Signals:** despite these challenges, future outlook, continues to thrive.

**Rule:** Simplify formulaic framing while retaining every challenge, forecast, and degree of certainty.

### E7. High-frequency AI vocabulary [P1]

**Signals:** additionally, delve, intricate, interplay, landscape, paradigm, synergy, tapestry, nuanced, multifaceted.

**Rule:** Use a context-equivalent term only; do not create a scene, example, or historical explanation.

### E8. Copula avoidance [P2]

**Signals:** serves as, stands as, represents, boasts, features, offers.

**Rule:** Prefer a direct copula or verb while preserving subject, attributes, quantities, and tense.

### E9. Negative parallelism [P2]

**Signals:** not only…but also, it is not just…it is, not merely.

**Rule:** Recast both propositions; never drop one side or strengthen their relationship.

### E10. False ranges [P2]

**Signals:** decorative “from X to Y” pairs that are not a real scale.

**Rule:** Preserve every endpoint, entity, and order while removing only the range framing.

### E11. Em-dash overuse [P2]

**Rule:** Change punctuation only outside protected quotes/code, without changing clause relationships.

### E12. Bold overuse / inline-header lists [P2]

**Rule:** Reduce decorative Markdown while preserving every label, item, order, and claim.

### E13. Chat residue / flattery [P1]

**Signals:** I hope this helps, great question, certainly, let’s dive in, would you like, let me know.

**Rule:** Remove only reader-directed chatbot residue. Preserve substantive statements that happen to follow it.

### E14. Filler phrases [P2]

**Signals:** in order to, due to the fact that, at this point in time, in the event that.

**Rule:** Shorten to an equivalent phrase without changing time, condition, ability, or certainty.

### E15. Excessive hedging [P2]

**Rule:** Collapse duplicated hedges to one expression with the same uncertainty; never turn a possibility into a fact.

### E16. Curly quotation marks [P3]

**Rule:** Detect only. Direct quotations, code, and protected spans remain byte-for-byte unchanged; normalization requires a separate explicit request.

### E17. Title Case headings [P3]

**Rule:** Adjust unprotected heading capitalization only. Do not change proper nouns, code, or quoted titles.

### E18. Repeated summaries [P1]

**Signals:** in summary, to recap, as mentioned above, as discussed earlier.

**Rule:** Remove only duplicated framing or duplicated text. Do not replace it with new recommendations or select a “best” option absent from the source.

### E19. Over-structured prose [P2]

**Rule:** Convert a short related list to prose only when all items, labels, ordering, and logical relationships remain intact.
