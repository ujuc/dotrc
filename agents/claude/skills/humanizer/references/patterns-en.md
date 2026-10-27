# English AI-Pattern Catalog

Fast English/mixed track. Each rule keeps every fact, citation, actor, stance, modality, degree, sequence, example and recommendation; leave a finding unresolved when no faithful rewrite exists.

| ID | Pattern [severity] | Signals | Rule |
|---|---|---|---|
| E1 | Importance inflation [P1] | pivotal, crucial, vital, testament, reminder, setting the stage, turning point, indelible mark | Reduce repeated unsupported framing; keep any importance claim |
| E2 | Media/notability display [P1] | independent coverage, leading expert, active social media presence | Keep every outlet, citation, count and notability claim; simplify only the syntax |
| E3 | Analytical `-ing` chains [P1] | highlighting, underscoring, ensuring, reflecting, symbolizing, contributing, fostering, showcasing | Recast the same propositions; add no explanation, source or example |
| E4 | Promotional language [P1] | vibrant, profound, groundbreaking, breathtaking, robust, seamless, cutting-edge, game-changing | Reduce repeated modifiers only when degree and stance stay; never swap in invented concrete facts |
| E5 | Vague sources / weasel words [P1] | experts argue, observers say, industry reports, several sources | Never invent a source; keep the attribution or leave it unresolved unless the input names the source |
| E6 | "Challenges and future prospects" formula [P1] | despite these challenges, future outlook, continues to thrive | Simplify the framing; keep every challenge, forecast and degree of certainty |
| E7 | High-frequency AI vocabulary [P1] | additionally, delve, intricate, interplay, landscape, paradigm, synergy, tapestry, nuanced, multifaceted | Use a context-equivalent term; create no scene, example or history |
| E8 | Copula avoidance [P2] | serves as, stands as, represents, boasts, features, offers | Prefer a direct copula or verb; keep subject, attributes, quantities and tense |
| E9 | Negative parallelism [P2] | not only…but also, it is not just…it is, not merely | Recast both propositions; never drop one or strengthen their relation |
| E10 | False ranges [P2] | decorative "from X to Y" that is not a real scale | Keep every endpoint, entity and order; remove only the range framing |
| E11 | Em-dash overuse [P2] | | Change punctuation only outside protected quotes/code, keeping clause relations |
| E12 | Bold overuse / inline-header lists [P2] | | Reduce decorative Markdown; keep every label, item, order and claim |
| E13 | Chat residue / flattery [P1] | I hope this helps, great question, certainly, let's dive in, would you like, let me know | Remove only reader-directed chatbot residue; keep substantive statements after it |
| E14 | Filler phrases [P2] | in order to, due to the fact that, at this point in time, in the event that | Shorten to an equivalent; keep time, condition, ability and certainty |
| E15 | Excessive hedging [P2] | | Collapse duplicate hedges to one with the same uncertainty; never turn a possibility into a fact |
| E16 | Curly quotation marks [P3] | | Detect only; normalizing needs a separate explicit request |
| E17 | Title Case headings [P3] | | Adjust unprotected heading capitalization only; not proper nouns, code or quoted titles |
| E18 | Repeated summaries [P1] | in summary, to recap, as mentioned above, as discussed earlier | Remove only duplicated framing or text; add no new recommendation or "best" option |
| E19 | Over-structured prose [P2] | | Turn a short related list into prose only when all items, labels, order and logic stay |
| E20 | Mannered prose [P2] | a flourish standing in for a plain statement ("a dial worth turning" for "a parameter worth varying"; "earns its keep" for "still matters") | Use the literal phrase only when it says exactly the same; keep deliberate figures (quotes, titles, a stated analogy, a sustained personal/essay voice); else leave unresolved |
