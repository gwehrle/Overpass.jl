module Overpass

using Preferences
using HTTP
using URIs
using Dates

export query, set_endpoint, status, turbo_url

# TYPES
Bbox = Union{Nothing, NTuple{4, Number}}
Center = Union{Nothing, NTuple{2, Number}}
struct Status
    connection_id::String
    server_time::DateTime
    endpoint::Union{Nothing, String}
    rate_limit::Int
    avalible_slots::Union{Nothing, Int}
end

# HARD-CODED URLS
DEFAULT_ENDPOINT = "https://overpass-api.de/api/"
OVERPASS_TURBO_URL = "https://overpass-turbo.eu/"

# include package files
include("shortcuts.jl")

"""
	query(query_or_file::String; bbox::Bbox=nothing, center::Center=nothing)::String

Sends a query to the Overpass API and retrieves the response as a string.

The query can be provided directly or by specifying the path to a `.ql` or `.overpassql` file. Supports replacement of shortcuts like `{{bbox}}` and `{{center}}`.

# Arguments
- `query_or_file::String`: The Overpass query string or path to a query file.
- `bbox::Bbox`: Optional bounding box `(min_lat, min_lon, max_lat, max_lon)` to replace `{{bbox}}` in the query.
- `center::Center`: Optional center point `(lat, lon)` to replace `{{center}}` in the query.

# Returns
- `String`: The response from the Overpass API.

# Notes
- To change the Overpass API endpoint, use the  [`set_endpoint`](@ref) function.
- Throws a `DomainError` if the query is invalid or the Overpass API returns an error.
"""
function query(
        query_or_file::String;
        bbox::Bbox = nothing,
        center::Center = nothing
)::String
    url = @load_preference("endpoint", DEFAULT_ENDPOINT) * "interpreter"

    query = get_query(query_or_file)
    query = replace_shortcuts(query, bbox, center)

    try
        # Start Overpass request
        @debug "Start request"
        resp = HTTP.post(url, body = query)

        @debug("Data recieved")
        return String(resp.body)
    catch error
        if isa(error, HTTP.StatusError) && error.status == 400
            str = String(error.response.body)

            # This regex matches an HTML error message wrapped in a `<p>` tag with a `<strong>` element:
            # - Captures:
            #   - `msg`: The error message text following `<strong>Error</strong>:` within the paragraph.
            # - Flags: i - Case insensitive
            pattern = r"<p><strong style=\"color:#FF0000\">Error<\/strong>:(?<msg>.+)<\/p>"i

            errormessages = join(
                collect(unescapehtml(match[:msg]) for match in eachmatch(pattern, str)),
                "\n")
            throw(DomainError(query, errormessages))
        else
            rethrow()
        end
    end
end

"""
	set_endpoint(endpoint::Union{Nothing, String}=nothing)::Bool

Sets or resets the Overpass API endpoint for all queries.

# Arguments
- `endpoint::Union{Nothing, String}`: The Overpass API endpoint URL.
  Must end with a trailing slash. If set to `nothing`, the default endpoint is restored.

# Returns
- `Bool`: `true` if the endpoint is successfully set, otherwise `false`.

# Notes
- If the endpoint does not have a trailing slash, the function issues a warning and does not set the endpoint.
"""
function set_endpoint(endpoint::Union{Nothing, String} = nothing)::Bool
    if isnothing(endpoint)
        delete_preferences!(@__MODULE__, "endpoint", export_prefs = false, force = true)
        @debug "Endpoint setting removed"
        return false
    end

    if !endswith(endpoint, "/")
        @warn "The endpoint url is expected to have a trailing slash.\n No new endpoint is set."
        return false
    end

    set_preferences!(
        @__MODULE__, "endpoint" => endpoint, export_prefs = false, force = true)
    @debug "Endpoint set to " endpoint
    return true
end

"""
	status()::Status

Fetches and parses the current status of the Overpass API.

# Returns
- `Status`: A struct containing the following fields:
  - `connection_id::String`: The connection ID assigned by the server.
  - `server_time::DateTime`: The current server time in UTC.
  - `endpoint::Union{Nothing, String}`: The announced endpoint (if any).
  - `rate_limit::Int`: The rate limit (requests per minute).
  - `avalible_slots::Union{Nothing, Int}`: The number of available slots for requests, or `nothing` if unavailable.

# Notes
- Use [`set_endpoint`](@ref) to modify the API endpoint before calling this function.
- Throws an error if the API status response cannot be parsed.
"""
function status()::Status
    url = @load_preference("endpoint", DEFAULT_ENDPOINT) * "status"

    response = HTTP.get(url)

    @debug "Status response" response

    # This regex extracts Overpass API status details from a formatted response:
    # - Captures:
    #   - `connection_id`: Connection ID as digits.
    #   - `server_time`: Current server time.
    #   - `endpoint`: (Optional) Announced endpoint URL.
    #   - `rate_limit`: API rate limit as digits.
    #   - `avalible_slots`: (Optional) Available slots as digits.
    # - Flags: i - Case insensitive
    # - Matches structured responses with fields like "Connected as: <id>", "Current time: <time>", etc.
    pattern = r"Connected\sas:\s(?<connection_id>\d+)\n"i *
              r"Current\stime:\s(?<server_time>[^\n]+)\n"i *
              r"(?:Announced\sendpoint:\s(?<endpoint>[^\n]+)\n)?"i *
              r"Rate\slimit:\s(?<rate_limit>\d+)\n"i *
              r"(?:(?<avalible_slots>\d+)\sslots\savailable\snow.)?"i

    matches = match(pattern, String(response.body))

    @debug "Status regex matches" matches

    status = Status(
        matches[:connection_id],
        DateTime(matches[:server_time], dateformat"yyyy-mm-ddTHH:MM:SSZ"),
        matches[:endpoint],
        parse(Int, matches[:rate_limit]),
        isnothing(matches[:avalible_slots]) ? nothing :
        parse(Int, matches[:avalible_slots])
    )

    return status
end

"""
	turbo_url(query_or_file::String)::String

Generates an Overpass Turbo URL for a given query.

This is useful for debugging queries visually in the Overpass Turbo interface.

# Arguments
- `query_or_file::String`: The Overpass query string or path to a query file.

# Returns
- `String`: The generated Overpass Turbo URL.

# Example
```julia
julia> turbo_url("[out:json];node[amenity=school](50.6,7.0,50.8,7.3);out;")
"https://overpass-turbo.eu/?Q=[out:json];node[amenity=school](50.6,7.0,50.8,7.3);out;"
```
"""
function turbo_url(query_or_file::String)::String
    query = get_query(query_or_file)

    return OVERPASS_TURBO_URL * "?Q=" * escapeuri(query)
end

"""
	unescapehtml(i::AbstractString)::AbstractString

Unescapes special HTML characters (`&`, `<`, `>`, `"`, `'`) in a string.

# Arguments
- `i::AbstractString`: The input string with HTML entities.

# Returns
- `AbstractString`: A string with HTML entities replaced by their corresponding characters.

# Example
```julia
julia> unescapehtml("Hello &lt;World&gt;!")
"Hello <World>!"
```
"""
function unescapehtml(i::AbstractString)::AbstractString
    # Inspired from HTTP.jl escapehtml()
    o = replace(i, "&amp;" => "&")
    o = replace(o, "&quot;" => "\"")
    o = replace(o, "&#39;" => "'")
    o = replace(o, "&lt;" => "<")
    o = replace(o, "&gt;" => ">")
    return o
end

"""
	get_query(query_or_file::String)::String

Determines if the input is a direct query string or a file path, and returns the query content.

# Arguments
- `query_or_file::String`: The Overpass query string or file path.

# Returns
- `String`: The query content as a string.

# Notes
- If the input ends with `.ql` or `.overpassql`, it is treated as a file path and the file's content is returned.
- If the input is not a file path, it is returned as-is.

# Example
```julia
julia> get_query("[out:json];node[amenity=school](50.6,7.0,50.8,7.3);out;")
"[out:json];node[amenity=school](50.6,7.0,50.8,7.3);out;"

julia> get_query("query.ql")
"Contents of query.ql"
```
"""
function get_query(query_or_file::String)::String
    if endswith(query_or_file, r".ql|.overpassql"i)
        @debug "Input is file"

        f = open(query_or_file, "r")
        s = read(f, String)
        close(f)

        return s
    end

    @debug "Input is query."
    return query_or_file
end

end
