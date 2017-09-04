-module(deathray_cowboy_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, _StartArgs) ->
    {ok, _} = deathray_cowboy:http_start(),
    deathray_cowboy_sup:start_link().

stop(_State) ->
    ok.
