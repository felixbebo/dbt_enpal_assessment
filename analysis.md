# Source Data Analysis

## Table Exploration

### `deal_changes`
- Main event table for the project, with 15,406 rows across 1,995 deals.
- Captures `deal_id`, `change_time`, `changed_field_key`, and `new_value`.
- Tracks deal creation, owner changes, stage transitions, and lost reasons.
- `stage_id` is the dominant change type, so this is the key table for funnel logic.
- Event ordering by `change_time` matters for timeline-based modeling.

### `activity`
- Activity event table with 4,579 rows.
- Contains `deal_id`, so it can be linked to the deal lifecycle.
- Key columns are `activity_id`, `type`, `assigned_to_user`, `deal_id`, `done`, and `due_to`.
- Event types are split across `meeting`, `sc_2`, `follow_up`, and `after_close_call`.
- `done` is almost evenly split, so completion status is useful for analysis.

### `fields`
- Metadata table that maps `FIELD_KEY` values to business concepts.
- The `stage_id` row contains the canonical 9 funnel steps in `FIELD_VALUE_OPTIONS`.
- Best source for naming the reporting stages.

### `stages`
- Lookup table for `stage_id` and `stage_name`.
- Useful as a simple stage reference table.
- The naming should be checked against `fields`, because the metadata is the more complete stage definition.

### `activity_types`
- Small lookup table for activity type codes.
- Maps technical values like `meeting` and `sc_2` to business-friendly names.
- Mostly a reference dimension.

### `users`
- Dimension table for owners and users.
- Contains basic attributes like `id`, `name`, `email`, and `modified`.
- Can be joined to `activity.assigned_to_user` and `deal_changes` owner changes.

## Conclusion

- It is sales funnel data.
- The three main entities are `deal`, `activity`, and `user`.
- `deal` represents the opportunity and moves through funnel stages.
  - Properties: `deal_id`, created timestamp, owner, stage, and lost reason.
  - It is modelled through the `deal_changes` event table, which stores a change timestamp for each changed field.
- `activity` is an event linked to a deal via `deal_id`.
  - Properties: `activity_id`, `deal_id`, type, assignee, due date, and done status.
  - The activity types are Sales Call 1, Sales Call 2, Follow Up Call, and After Close Call.
- `user` represents the sales person.
  - Properties: `id`, `name`, `email`, and last modified.

## Analysis Opportunities
- Growth metrics, deal counts, and volume trends over time.
- Funnel progression, drop-offs, conversion performance, and lost reason analysis.
- Cycle time and speed through the deal stages.
- Relationship between activities and deals, including the impact of certain activities on deal outcomes and the completeness and timeliness of activities on deal performance.
- Sales user performance (top/worst), comparing deal owners versus activity assignees.
