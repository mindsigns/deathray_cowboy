-module(deathray_channel_router).
-export([init/2]).

init(Req, Page) ->
    {ok, ResponseBody} = deathray_cowboy_templates_base:render(),
    Reply = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], ResponseBody, Req),
    {ok, Reply, Page}.
