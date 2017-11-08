-module(channel_router).
-export([init/2]).

init(Req, Page) ->
	N = cowboy_req:binding(channel,Req),
	Y = deathray_utils:str_to_int(N),
	{Pages, Ids} = pagination:posts(Y),
	List = [db_tools:read(X) || X <- Ids],
	Nentry = lists:flatten(List),
	Entries = lists:map(fun deathray_utils:format/1, Nentry),
	PageTitle = "Channel" ++ N,

  {ok, ResponseBody} = templates_page:render([{entries, Entries}, {pagetitle, PageTitle}, {pages, Pages}, {channel, Y}]),
  Reply = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], ResponseBody, Req),
  {ok, Reply, Page}.
