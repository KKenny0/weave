# Phase 1: Collect

Gather primary sources. Three input cases — handle each explicitly.

## Case 1: User provided sources (URL / PDF / file / pasted text)

Skip auto-scout. Use what the user gave. Move directly to the workflow-specific Phase 2.

For URL sources, normal fetch flow:

- Try `mcp__web-reader__webReader` first (owns the proxy cascade + platform routing)
- If failing, try web cache
- If still failing, follow the failure handling below

### If user URL fails AND you can't ask the user (non-interactive context)

Triggered when fetch fails (404, paywall, TCP timeout, MCP backend error) AND no way to ask the user (eval environment, background agent, user stepped away).

Don't fabricate. Don't silently swap sources. Two options, in priority order:

1. **Replace with closest-match real source + flag** — use `WebSearch "{topic from URL}"` to find the most authoritative real article on the same topic, fetch it, use it. In the delivery report (`voice-pass.md` Step 4), explicitly say: "User-provided URL {X} failed ({error}). Substituted with {Y} fetched from {Z}. User can supply alternative if needed."
2. **Abort + write fetch-failure report** — if the URL is uniquely important (specific paper / specific interview / user named it explicitly) and no real substitute exists, stop. Write a short report: "Could not fetch user-provided source. Tried: native fetch, mcp__web-reader__webReader, web cache. All failed. Error details: {...}. Please supply an alternative URL or local file."

Default to option 1 for general "research this topic" prompts. Default to option 2 when the user named a specific artifact (paper title, interview name, exact URL).

Never silently swap — always flag in delivery report.

## Case 2: User provided topic only (no sources)

Run auto-scout:

1. **Search**: `WebSearch "{topic}"` — take top 10 results.
2. **Filter**: drop marketing / SEO farm / product-only pages. Keep: papers (arxiv / journals), official engineering blogs, technical docs, long-form articles, repo READMEs.
3. **Fetch**: for each filtered URL (target 5-10), call `mcp__web-reader__webReader`. On failure, try web cache; if still failing, skip.
4. **Report**: tell user "Auto-scouted N sources: [list]. If you have specific sources you want me to read, add them now."
5. **Proceed** to workflow-specific Phase 2 with fetched content as the source set.

If fewer than 3 quality sources remain after filter, **stop and tell the user** — web search can't cover this topic well; ask them to supplement with specific URLs, papers, or search terms.

## Case 3: User provided neither topic nor sources

Stop and ask: "What do you want to research?" Get a topic, go to Case 2.

## Never

- Don't fabricate sources.
- Don't write anything from general knowledge before Phase 1 completes.
- Don't skip auto-scout when user only gave a topic. The whole pipeline is evidence-grounded — no sources means no article.
