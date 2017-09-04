%% @author jon <jon@deathray.tv>
%% @copyright 2011-2015 : jon.
%% @doc Utilities resource.

-module(deathray_utils).

-export([
         format/1,
         fformat/1,
         str_to_int/1,
         term_to_string/1,
         import/1,
         update/1,
         ok_ids/0
        ]).

-include("../include/deathray.hrl").

-include_lib("stdlib/include/qlc.hrl").

term_to_string(Term) ->
  io_lib:format("~p", [Term]).

str_to_int(String) ->
    case string:to_integer(String) of
        {error, _} -> Integer = 1,
                                Integer;
        _ -> {Integer, _} = string:to_integer(String),
                Integer
    end.

import(File) ->
    case filelib:is_file(File) of
        false -> error;
        true  ->
            case file:consult(File) of
                {error, _} -> io:format("~nError: Can not import ~p. Bad format.~n", [File]);
                {ok, Data} ->
                    [{Title, Text, Image}] = Data,
                    {atomic, ok} = db_tools:add(Title, Text, Image),
                    io:format("Added ~p~n", [Title])
            end
    end.

update(File) ->
    case filelib:is_file(File) of
        false -> error;
        true  ->
            {_,Data} =  file:consult(File),
            [{entry, Id, Title, Text, Image, Pubdate}] = Data,
            {atomic, ok} = db_tools:update(Id, Title, Text, Image, Pubdate),
            io:format("Updated ~p~n", [Title])
    end.


fformat(Entry) ->
    {Title, Text, Image} = {Entry#entry.title, Entry#entry.text, Entry#entry.image},
    {Title, Text, Image}.

format(Entry) ->
    [{"id", Entry#entry.id},
     {"title", Entry#entry.title},
     {"text", Entry#entry.text},
     {"image", Entry#entry.image},
     {"pubdate", Entry#entry.pubdate}].

ok_ids() ->
    Ids = [X||{entry, X, _, _, _, _} <- db_tools:showall()],
    Ids.
