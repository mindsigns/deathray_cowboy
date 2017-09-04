-module(contact_router).
-export([init/2]).

init(Req, Page) ->
  PageTitle = "Contact",

  {ok, ResponseBody} = templates_contact:render([{pagetitle, PageTitle}]),
  Reply = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], ResponseBody, Req),
  {ok, Reply, Page}.
