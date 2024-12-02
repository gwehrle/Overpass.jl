module Overpass

using Preferences
using HTTP
using URIs
using Dates
using TimeZones

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
include(shortcuts.jl)

"""
    query(query_or_file::String; <keyword arguments>)::String

Get a response to `query_or_file` from Overpass API.

The query can be provided directly or as a path to a `.ql`/`.overpassql` file.

# Arguments
- `bbox::NTuple{4, Number}`: Replacement value for `{{bbox}}` in query.
- `center::NTuple{2, Number}`: Replacement value for `{{center}}` in query.

See also [`set_endpoint`](@ref) to change Overpass API endpoint.
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
            regex = r"""<p><strong style=\"color:#FF0000\">Error<\/strong>:(?<msg>.+)<\/p>"""i
            errormessages = join(
                collect(unescapehtml(match[:msg]) for match in eachmatch(regex, str)),
                "\n")
            throw(DomainError(query, errormessages))
        else
            rethrow()
        end
    end
end

"""
    set_endpoint(endpoint::Union{Nothing, String})

Change Overpass endpoint for all functions.

Endpoint needs to be an URL with trailing slash.
If set to `nothing` the default endpoint is used.
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

Receive current Status of Overpass API.

Status provides the following fields:
- connection_id::String
- server_time::DateTime
- endpoint::Union{Nothing, String}
- rate_limit::Int
- avalible_slots::Union{Nothing, Int}

See also [`set_endpoint`](@ref) to change Overpass API endpoint.
"""
function status()::Status
    url = @load_preference("endpoint", DEFAULT_ENDPOINT) * "status"

    response = HTTP.get(url)

    @debug "Status response" response

    regex = r"Connected\sas:\s(?<connection_id>\d+)\n"i *
            r"Current\stime:\s(?<server_time>[^\n]+)\n"i *
            r"(?:Announced\sendpoint:\s(?<endpoint>[^\n]+)\n)?"i *
            r"Rate\slimit:\s(?<rate_limit>\d+)\n"i *
            r"(?:(?<avalible_slots>\d+)\sslots\savailable\snow.)?"i

    matches = match(regex, String(response.body))

    @debug "Status regex matches" matches

    status = Status(
        matches[:connection_id],
        DateTime(matches[:server_time], dateformat"yyyy-mm-ddTHH:MM:SSz"),
        matches[:endpoint],
        parse(Int, matches[:rate_limit]),
        isnothing(matches[:avalible_slots]) ? nothing :
        parse(Int, matches[:avalible_slots])
    )

    return status
end

"""
    turbo_url(query_or_file::String)::String

Transform Overpass Query to Overpass Turbo URL.

The query can be provided directly or as a path to a `.ql`/`.overpassql` file.
Can be helpful to debug queries.
"""
function turbo_url(query_or_file::String)::String
    query = get_query(query_or_file)

    return OVERPASS_TURBO_URL * "?Q=" * escapeuri(query)
end

"""
    unescapehtml(i::String)

Returns a string with special HTML characters unescaped: &, <, >, ", '
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

Decide if query is directly passed or from file.
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
