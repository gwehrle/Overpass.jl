using Overpass
using Test
using BrokenRecord: configure!, playback
using HTTP
using Preferences
using Dates

configure!(;
    path = string(@__DIR__, "/HTTP/"), extension = "bson", ignore_headers = ["User-Agent"])

@testset "Overpass.jl" begin
    @testset "query" begin
        @test playback(
            () -> Overpass.query("[out:json];node[amenity=drinking_water](48.224410300027,16.36058699342046,48.22702986850222,16.364722959721423);out;"),
            "op-query") != ""

        @test playback(
            () -> Overpass.query("[out:json];node[amenity=drinking_water]({{bbox}});out;",
                bbox = (48.224410300027, 16.36058699342046,
                    48.22702986850222, 16.364722959721423)),
            "op-query") != ""

        @test playback(
            () -> Overpass.query(
                string(@__DIR__, "/waterfountains.overpassql"), bbox = (
                    48.224410300027, 16.36058699342046,
                    48.22702986850222, 16.364722959721423)),
            "op-query") != ""

        @test_throws ErrorException playback(() -> Overpass.query("noddddddde;out;"),
            "error")
    end

    @testset "set_endpoint" begin
        @testset "Add endpoint" begin
            Overpass.set_endpoint("https://overpass-api.de/api/")
            @test load_preference("Overpass", "endpoint") == "https://overpass-api.de/api/"
        end

        @testset "Unset endpoint" begin
            Overpass.set_endpoint()
            @test isnothing(load_preference("Overpass", "endpoint"))
        end

        @testset "Force trailing slash" begin
            @test_logs (:warn,
                "The endpoint url is expected to have a trailing slash.\n No new endpoint is set.") Overpass.set_endpoint("https://overpass-api.de/api")
            @test isnothing(load_preference("Overpass", "endpoint"))
        end
    end

    @testset "status" begin
        @testset "default endpoint" begin
            status = playback(() -> Overpass.status(), "op-status")

            @test status isa Overpass.Status
            @test status.connection_id == "3158479246"
            @test status.server_time == DateTime("2024-11-11T23:37:10")
            @test status.endpoint == "lambert.openstreetmap.de/"
            @test status.rate_limit == 6
            @test status.avalible_slots == 6
        end

        @testset "ru endpoint" begin
            Overpass.set_endpoint("https://maps.mail.ru/osm/tools/overpass/api/")
            status = playback(() -> Overpass.status(), "op-status-ru")

            @test status isa Overpass.Status
            @test status.connection_id == "1293416468"
            @test status.server_time == DateTime("2024-11-11T23:56:34")
            @test isnothing(status.endpoint)
            @test status.rate_limit == 0
            @test isnothing(status.avalible_slots)

            Overpass.set_endpoint() #reset
        end

        @testset "coffee endpoint" begin
            Overpass.set_endpoint("https://overpass.private.coffee/api/")
            status = playback(() -> Overpass.status(), "op-status-coffee")

            @test status isa Overpass.Status
            @test status.connection_id == "177472788"
            @test status.server_time == DateTime("2024-11-12T00:03:37")
            @test status.endpoint == "none"
            @test status.rate_limit == 0
            @test isnothing(status.avalible_slots)

            Overpass.set_endpoint() #reset
        end

        @testset "JP endpoint" begin
            Overpass.set_endpoint("https://overpass.osm.jp/api/")
            status = playback(() -> Overpass.status(), "op-status-jp")

            @test status isa Overpass.Status
            @test status.connection_id == "1293416468"
            @test status.server_time == DateTime("2024-11-12T00:04:21")
            @test status.endpoint == "none"
            @test status.rate_limit == 0
            @test isnothing(status.avalible_slots)

            Overpass.set_endpoint() #reset
        end
    end

    @testset "turbo_url" begin
        url = "https://overpass-turbo.eu/?Q=%5Bout%3Ajson%5D%3Bnode%5Bamenity%3Ddrinking_water%5D%28%7B%7Bbbox%7D%7D%29%3Bout%3B"
        @test Overpass.turbo_url("[out:json];node[amenity=drinking_water]({{bbox}});out;") ==
              url
        @test Overpass.turbo_url(string(@__DIR__, "/waterfountains.overpassql")) == url
    end

    @testset "unsescapehtml" begin
        @test Overpass.unescapehtml("abc") == "abc"
        @test Overpass.unescapehtml("&lt;b&gt; &quot;test&quot; &amp;") == "<b> \"test\" &"
    end

    @testset "get_query" begin
        @testset "pass through normal string" begin
            @test Overpass.get_query("[out:json];node[amenity=drinking_water]({{bbox}});out;") ==
                  "[out:json];node[amenity=drinking_water]({{bbox}});out;"
        end

        @testset "read file" begin
            @test Overpass.get_query(string(@__DIR__, "/waterfountains.overpassql")) ==
                  "[out:json];node[amenity=drinking_water]({{bbox}});out;"
        end

        @testset "file not found" begin
            @test_throws SystemError Overpass.get_query("nofile.ql")
        end
    end

    @testset "replace_shortcuts" begin
        @test Overpass.replace_shortcuts("abc", nothing, nothing) == "abc"

        @test Overpass.replace_shortcuts("abc", (48.0, 16.0, 49.0, 17.0), (5, 6)) == "abc"

        @test Overpass.replace_shortcuts(
            "Lorem {{bbox}} {{center}} ipsum", (1, 2, 3, 4), (5, 6)) ==
              "Lorem 1,2,3,4 5,6 ipsum"
        @test Overpass.replace_shortcuts(
            "Lorem {{ bbox }} {{center       }} ipsum", (1, 2, 3, 4), (5, 6)) ==
              "Lorem 1,2,3,4 5,6 ipsum"
        @test Overpass.replace_shortcuts(
            "Lorem {{ bbox \n}} {{\ncenter \n\n      }} ipsum", (1, 2, 3, 4), (5, 6)) ==
              "Lorem 1,2,3,4 5,6 ipsum"

        @test_throws MissingException Overpass.replace_shortcuts(
            "{{bbox}}", nothing, nothing)
        @test_throws MissingException Overpass.replace_shortcuts(
            "{{center}}", nothing, nothing)
        @test_throws DomainError Overpass.replace_shortcuts(
            "{{ custom }}", nothing, nothing)
    end
end

include("Aqua.jl")
