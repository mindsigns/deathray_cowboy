-module(transmit_router).
-export([init/2]).

init(Req, Page) ->
    N = cowboy_req:binding(id, Req),
	Y = deathray_utils:str_to_int(N),
	Tentry = db_tools:read(Y),
	Entries = lists:map(fun deathray_utils:format/1, Tentry),
	PageTitle = "Transmit",

    {ok, ResponseBody} = templates_base:render([{pagetitle, PageTitle}, {entries, Entries}]),
    Reply = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], ResponseBody, Req),
    {ok, Reply, Page}.
