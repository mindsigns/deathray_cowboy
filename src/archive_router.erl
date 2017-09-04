-module(archive_router).
-export([init/2]).

init(Req, Page) ->
    Tentry = db_tools:showall(),
    Nentry = lists:reverse(lists:keysort(2, Tentry)),
    Entries = lists:map(fun deathray_utils:format/1, Nentry),
    PageTitle = "Archive",

    {ok, ResponseBody} = templates_archive:render([{pagetitle, PageTitle}, {entries, Entries}]),
    Reply = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], ResponseBody, Req),
    {ok, Reply, Page}.
