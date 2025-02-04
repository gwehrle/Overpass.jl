"""
	replace_shortcuts(
		query::AbstractString, bbox::Bbox, center::Center
	)::AbstractString

Replaces predefined shortcuts (e.g., `{{bbox}}`, `{{center}}`, `{{date}}`)
in the given Overpass query string with their corresponding values.

# Arguments
- `query::AbstractString`: The Overpass query string containing shortcuts.
- `bbox::Bbox`: A bounding box tuple `(min_lat, min_lon, max_lat, max_lon)`
  to replace `{{bbox}}` in the query. Pass `nothing` to skip replacement.
- `center::Center`: A center point tuple `(lat, lon)` to replace `{{center}}`
  in the query. Pass `nothing` to skip replacement.

# Returns
- `AbstractString`: The modified query string with all applicable shortcuts replaced.

# Notes
- The function checks for any unreplaced shortcuts and throws an error if found.
"""
function replace_shortcuts(
        query::AbstractString, bbox::Bbox = nothing, center::Center = nothing)::AbstractString
    query = replace_bbox_shortcuts(query, bbox)
    query = replace_center_shortcuts(query, center)
    query = replace_date_shortcuts(query)
    query = remove_style_shortcuts(query)
    check_remaining_shortcuts(query)

    return query
end

"""
	replace_bbox_shortcuts(
		query::AbstractString, bbox::Bbox
	)::AbstractString

Replaces the `{{bbox}}` shortcut in the query with the provided bounding box.

# Arguments
- `query::AbstractString`: The Overpass query string containing the `{{bbox}}` shortcut.
- `bbox::Bbox`: A bounding box tuple `(min_lat, min_lon, max_lat, max_lon)`.

# Returns
- `AbstractString`: The query with `{{bbox}}` replaced by the bounding box,
  or unchanged if `bbox` is `nothing`.

# Notes
- If `bbox` is `nothing`, the query is returned without modifications.
"""
function replace_bbox_shortcuts(query::AbstractString, bbox::Bbox)::AbstractString
    if !isnothing(bbox)
        query = replace(query, r"\{\{\s*bbox\s*\}\}"i => join(bbox, ","))
        @debug "query after bbox replacement" query
    end

    return query
end

"""
	replace_center_shortcuts(
		query::AbstractString, center::Center
	)::AbstractString

Replaces the `{{center}}` shortcut in the query with the provided center point.

# Arguments
- `query::AbstractString`: The Overpass query string containing the `{{center}}` shortcut.
- `center::Center`: A center point tuple `(lat, lon)`.

# Returns
- `AbstractString`: The query with `{{center}}` replaced by the center point,
  or unchanged if `center` is `nothing`.

# Notes
- If `center` is `nothing`, the query is returned without modifications.
"""
function replace_center_shortcuts(query::AbstractString, center::Center)::AbstractString
    if !isnothing(center)
        query = replace(query, r"\{\{\s*center\s*\}\}"i => join(center, ","))
        @debug "query after center replacement" query
    end

    return query
end

"""
	replace_date_shortcuts(query::AbstractString)::AbstractString

Replaces `{{date}}` shortcuts in the query with the current or calculated date.

# Arguments
- `query::AbstractString`: The Overpass query string containing `{{date}}` shortcuts.

# Returns
- `AbstractString`: The query with `{{date}}` shortcuts replaced with their respective dates.

# Notes
- Supports offsets like `{{date:-7days}}` for relative dates.
- The output format is ISO 8601 with a `Z` suffix for UTC.
- See: https://wiki.openstreetmap.org/wiki/Overpass_turbo/Extended_Overpass_Turbo_Queries#Available_Shortcuts
"""
function replace_date_shortcuts(query::AbstractString)::AbstractString
    if occursin(r"\{\{\s*?date"i, query)
        # Get the current date and time
        current_date = now(UTC)

        # Map string units to Dates.Period constructors
        period_map = Dict(
            "year" => Year,
            "month" => Month,
            "day" => Day,
            "week" => Week,
            "hour" => Hour,
            "minute" => Minute,
            "second" => Second
        )

        # This regex matches a "date" placeholder in the format "{{date: <value> <unit>s}}" within double curly braces.
        # - Captures:
        #   - `value`: An optional numeric value (e.g., "-3", "+1").
        #   - `unit`: An optional time unit (e.g., "year", "month", "day"), optionally pluralized.
        # - Flags: i - matching variations like "{{DATE}}" or "{{Date}}".
        pattern = r"\{\{\s*date\s*(?::\s*(?<value>-?\+?[0-9]+)\s*(?<unit>year|month|day|week|hour|minute|second)s?)?\s*\}\}"i

        for match in eachmatch(pattern, query)
            # Extract captured groups
            duration_value, duration_unit = match.captures
            @debug "" match.captures

            # Compute the replacement date
            replacement_date = if duration_value !== nothing && duration_unit !== nothing
                # Parse the duration and compute the past date
                value = parse(Int, duration_value)
                @debug "parsed duration value" value
                period_constructor = get(period_map, lowercase(duration_unit), nothing)
                duration = period_constructor(value)  # Create the period object
                @debug "" duration
                current_date - duration
            else
                # Use current date if no duration is provided
                current_date
            end
            # make replacement_date a String in the correct format and appand 'Z' for UTC
            replacement_date = Dates.format(replacement_date, ISODateTimeFormat) * "Z"
            @debug "replacement String" replacement_date

            # Replace the match in the query string
            query = replace(query, match.match => replacement_date)
        end
    end

    @debug "query afer date replacement" query
    return query
end

"""
	remove_style_shortcuts(query::AbstractString)::AbstractString

Removes `{{style:}}` shortcuts in the query.

# Arguments
- `query::AbstractString`: The Overpass query string containing `{{style}}` shortcuts.

# Returns
- `AbstractString`: The query with `{{style}}` shortcuts removed.
"""
function remove_style_shortcuts(query::AbstractString)::AbstractString
    return replace(query, r"\{\{\s*style:.*?\}\}"is => "")
end

"""
	check_remaining_shortcuts(query::AbstractString)::Nothing

Checks for unreplaced Overpass shortcuts in the query and throws errors if found.

# Arguments
- `query::AbstractString`: The Overpass query string to validate.

# Returns
- `Nothing`: Throws an error if any unreplaced shortcuts remain.

# Errors
- `MissingException`: Thrown if mandatory shortcuts like `{{bbox}}` or `{{center}}` are missing.
- `DomainError`: Thrown if an unsupported shortcut is found.
"""
function check_remaining_shortcuts(query::AbstractString)::Nothing

    # This regex matches placeholders in double curly braces ({{...}}) with special handling for "date":
    # - Captures:
    #   - `all`: The entire placeholder content.
    #   - `is_date`: Matches "date" keyword if present.
    #   - `date_value`: The value after "date" (e.g., "misspelled", excluding colons).
    #   - `other`: Any other placeholder content (e.g., "bbox", "center").
    # - Flags: i - Case insensitive
    pattern = r"\{\{\s*(?<all>(?<is_date>date)\s*[:+]{1,2}\s*(?<date_value>[^:{}\s][^{}]*?)|(?<other>.+?))\s*\}\}"i

    for match in eachmatch(pattern, query)
        if match[:other] == "bbox"
            throw(MissingException("""{{bbox}} found in query, but no value specified.
            Use keyword argument "bbox": Overpass.query(…, bbox = (48.22, 16.36, 48.22, 16.36))."""))
        elseif match[:other] == "center"
            throw(MissingException("""{{center}} found in query, but no value specified.
            Use keyword argument "center": Overpass.query(…, center = (48.22, 16.36))."""))
        elseif !isnothing(match[:is_date])
            throw(DomainError(
                query, """Did not recognize time unit for date shortcut: \"""" *
                       match[:date_value] * """\".
Please consult the documentation for supported time units."""))
        else
            throw(DomainError(
                query, """Unsupported shortcut in query: \"""" * match.match * """\".
            Please consult the documentation for supported shortcuts."""))
        end
    end
end
