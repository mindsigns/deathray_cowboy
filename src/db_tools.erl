%% @author jon <jon@deathray.tv>
%% @copyright 2011-2015 : jon.
%% @doc Database resource.

-module(db_tools).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").

-include("../include/deathray.hrl").

reset() ->
	mnesia:stop(),
	mnesia:delete_schema([node()]),
	mnesia:create_schema([node()]),
	mnesia:start(),

	mnesia:create_table(entry, [{disc_copies, [node()]}, {attributes, record_info(fields, entry)}]),
	mnesia:create_table(timestamp, [{disc_copies, [node()]}, {attributes, record_info(fields, timestamp)}]),
	mnesia:create_table(unique_ids, [{disc_copies, [node()]}, {attributes, record_info(fields, unique_ids)}]).

transaction(F) ->
	case mnesia:transaction(F) of
		{atomic, Result} ->
			Result;
		{aborted, _Reason} ->
			[]
	end.	

read(Id) ->
    do(qlc:q([X || X <- mnesia:table(entry),
                        X#entry.id =:= Id])).

write(Rec) ->
	F = fun() ->
			mnesia:write(Rec)
	end,
	mnesia:transaction(F).

delete(Id) ->
	F = fun() ->
    Oid = {entry, Id},
			mnesia:delete(Oid)
	end,
	mnesia:transaction(F).

add(Title,Text,Image) ->
    {{Year,Month,Day},{Hour,Minute,_}} = erlang:localtime(),
    Id = mnesia:dirty_update_counter(unique_ids, record_type, 1),
    Pubdate = lists:flatten(io_lib:format("~p/~p/~p@~p:~p",[Month, Day, Year, Hour, Minute])),
    Row = #entry{id=Id, title=Title, text=Text, image=Image, pubdate=Pubdate},
    Fun = fun() ->
        mnesia:write(Row)
    end,
    mnesia:transaction(Fun).

dump(File, Id) ->
    %[{_,Id, Title, Text, Image, Pubdate}] = db_tools:read(Id),
    Entry = db_tools:read(Id),
    {ok, S} = file:open(File, write),
    lists:foreach(fun(X) -> io:format(S, "~p.~n",[X]) end, Entry),
    file:close(S).

update(Id,Title,Text,Image,Pubdate) ->
    Row = #entry{id=Id, title=Title, text=Text, image=Image, pubdate=Pubdate},
    Fun = fun() ->
        mnesia:write(Row)
    end,
    mnesia:transaction(Fun).

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

sort(Table) ->
    lists:reverse(lists:keysort(2, showall(Table))).

showall() ->
    do(qlc:q([X || X <- mnesia:table(entry)])).
showall(Table) ->
    do(qlc:q([X || X <- mnesia:table(Table)])).

