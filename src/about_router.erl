-module(about_router).
-export([init/2]).

init(Req, Page) ->
  PageTitle = "About",

  {ok, ResponseBody} = templates_about:render([{pagetitle, PageTitle}]),
  Reply = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], ResponseBody, Req),
  {ok, Reply, Page}.
