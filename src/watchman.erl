%% @copyright 2015 jon
%% @author jon <jon@deathray.tv>
%%
%% @doc Check for changes in file and load when updated.

-module(watchman).
-author("jon <jon@deathray.tv>").

-include("../include/deathray.hrl").
-include_lib("stdlib/include/qlc.hrl").

-define(Filename, "priv/static/images/deathray.dat").

%-include_lib("kernel/include/file.hrl").

-behaviour(gen_server).
-export([start/0, start_link/0]).
-export([stop/0]).
-export([checkstamp/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {last, tref}).

%% External API

%% @spec start() -> ServerRet
%% @doc Start the reloader.
start() ->
    gen_server:start({local, ?MODULE}, ?MODULE, [], []).

%% @spec start_link() -> ServerRet
%% @doc Start the reloader.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% @spec stop() -> ok
%% @doc Stop the reloader.
stop() ->
    gen_server:call(?MODULE, stop).

%% gen_server callbacks

%% @spec init([]) -> {ok, State}
%% @doc gen_server init, opens the server in an initial state.
init([]) ->
    {ok, TRef} = timer:send_interval(timer:seconds(30), doit),
    {ok, #state{last = stamp(), tref = TRef}}.
    %{ok, TRef}.

%% @spec handle_call(Args, From, State) -> tuple()
%% @doc gen_server callback.
handle_call(stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call(_Req, _From, State) ->
    {reply, {error, badrequest}, State}.

%% @spec handle_cast(Cast, State) -> tuple()
%% @doc gen_server callback.
handle_cast(_Req, State) ->
    {noreply, State}.

%% @spec handle_info(Info, State) -> tuple()
%% @doc gen_server callback.
handle_info(doit, State) ->
    checkstamp(?Filename),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

%% @spec terminate(Reason, State) -> ok
%% @doc gen_server termination callback.
terminate(_Reason, State) ->
    {ok, cancel} = timer:cancel(State#state.tref),
    ok.

%% @spec code_change(_OldVsn, State, _Extra) -> State
%% @doc gen_server code_change callback (trivial).
code_change(_Vsn, State, _Extra) ->
    {ok, State}.

%% Internal API
checkstamp(Filename) ->
    Current = calendar:datetime_to_gregorian_seconds(filelib:last_modified(Filename)),
    case db_tools:showall(timestamp) of
        [] -> 
            Current = calendar:datetime_to_gregorian_seconds(filelib:last_modified(Filename)),
            {atomic, ok} = updatestamp(Current, Filename);
        [{timestamp, _,_}] ->
            Tstamp = db_tools:showall(timestamp),
            [#timestamp{id=_, modtime=Last}] = Tstamp,
            case (string:equal([Last], [Current])) of
                false -> updatestamp(Current, Filename);
                true  -> ok
            end
    end.

updatestamp(Modtime, Filename) ->
    deathray_utils:import(Filename),
    Row = #timestamp{id=1, modtime=Modtime},
    Fun = fun() ->
        mnesia:write(Row)
    end,
    mnesia:transaction(Fun).

stamp() ->
        erlang:localtime().

