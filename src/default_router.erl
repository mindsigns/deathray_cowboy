-module(default_router).
-export([init/2]).

init(Req, Page) ->
  Tentry = db_tools:showall(),
  Rentry = lists:reverse(lists:keysort(2, Tentry)),
  Centry = lists:sublist(Rentry, 10),
  Entries = lists:map(fun deathray_utils:format/1, Centry),
  PageTitle = "Main",

  {ok, ResponseBody} = templates_base:render([{entries, Entries}, {pagetitle, PageTitle}]),
  Reply = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], ResponseBody, Req),
  {ok, Reply, Page}.
