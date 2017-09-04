%% @author jon <jon@deathray.tv>
%% @copyright 2015 : jon.
%% @doc Paginate pages

-module(pagination).
-compile(export_all).

-define(PerPage, 10).

-include_lib("stdlib/include/qlc.hrl").

-include("../include/deathray.hrl").

posts(0) ->
    ID_List = lists:reverse(lists:sort(deathray_utils:ok_ids())),
    Posts = lists:sublist(ID_List, ?PerPage),
    Pages = (erlang:length(ID_List) + ?PerPage - 1) div ?PerPage,
    {Pages,Posts};
posts(PageNumber) ->
    Offset = PageNumber * ?PerPage,
    ID_List = lists:reverse(lists:sort(deathray_utils:ok_ids())),
    Pages = ((erlang:length(ID_List) + ?PerPage - 1) div ?PerPage) - 1,
    case PageNumber =< Pages of
        true -> Posts = lists:sublist(ID_List, Offset,?PerPage),
                  {Pages,Posts};
        false -> 
            case PageNumber =:= Pages of
                true -> Posts = lists:nthtail(Offset, ID_List),
                            {Pages,Posts};
                false ->    {0, []}
            end
    end.
