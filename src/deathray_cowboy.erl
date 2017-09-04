-module(deathray_cowboy).
-export([http_start/0]).

-define(PRIVDIR, code:priv_dir(?MODULE)).
-define(COMPILE_OPTS, [{out_dir, ?PRIVDIR ++ "/templates-compiled/"}]).

http_start() ->
    do_erlydtl_start(),
    do_cowboy_start().

do_erlydtl_start() ->
    {ok, Templates} = application:get_env(?MODULE, erlydtl_templates),
    [{ok, _} = erlydtl:compile_file(?PRIVDIR ++ File, Mod, ?COMPILE_OPTS) || {File, Mod} <- Templates].

do_cowboy_start() ->
    {Ip, Port, Workers, Dispatch} = do_cowboy_configure(),
    cowboy:start_http(http, Workers,
        [{ip, Ip}, {port, Port}],
        [{env, [{dispatch, Dispatch}]}]
    ).

do_cowboy_configure() ->
    {ok, Ip} = application:get_env(?MODULE, ip_address),
    {ok, Port} = application:get_env(?MODULE, port),
    {ok, Workers} = application:get_env(?MODULE, workers),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", default_router, <<"base.html">>},
            {"/transmit/[:id]", transmit_router, <<"transmit.html">>},
            {"/channel/[:channel]", channel_router, <<"page.html">>},
            {"/archive", archive_router, <<"archive.html">>},
            {"/contact", contact_router, <<"contact.html">>},
            {"/about", about_router, <<"about.html">>},
            {"/static/[...]", cowboy_static, {priv_dir, deathray_cowboy, "static"}},
            {"/[...]", cowboy_static, {priv_dir, deathray_cowboy, "pages"}}
        ]}
    ]),
    {Ip, Port, Workers, Dispatch}.
