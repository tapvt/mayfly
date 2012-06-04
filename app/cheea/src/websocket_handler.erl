-module(websocket_handler).
-behaviour(cowboy_http_handler).
-behaviour(cowboy_http_websocket_handler).
-export([init/3, handle/2, terminate/2]).
-export([websocket_init/3, websocket_handle/3,
    websocket_info/3, websocket_terminate/3]).

init({_Any, http}, Req, []) ->
    case cowboy_http_req:header('Upgrade', Req) of
        {undefined, Req2}        -> {ok, Req2, undefined};
        {<<"websocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket};
        {<<"WebSocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket}
    end.

handle(Req, State) ->
    {ok, Req2} = cowboy_http_req:reply(200, [{'Content-Type', <<"application/json">>}], "", Req),
    {ok, Req2, State}.

terminate(_Req, _State) -> ok.

websocket_init(_Any, Req, []) ->
    {Chat, _Req2} = cowboy_http_req:binding(chat, Req),
    Key = {?MODULE, Chat},
    gproc:reg({p, l, Key}),
    gproc:send({p, l, Key}, {self(), Key, jiffy:encode(
        {[{<<"name">>, 'MAYFLY'}, {<<"msg">>, 'someone joined'}]}
        )}),
    {ok, Req, Chat, hibernate}.

websocket_handle({text, Msg}, Req, State) ->
    Key = {?MODULE, State},
    gproc:send({p, l, Key}, {self(), Key, Msg}),
    {ok, Req, State};
websocket_handle(_Any, Req, State) -> {ok, Req, State}.

websocket_info({_Pid, {?MODULE, State}, Msg}, Req, State) -> {reply, {text, clean_msg(Msg)}, Req, State, hibernate};
websocket_info(_Info, Req, State) -> {ok, Req, State, hibernate}.

websocket_terminate(_Reason, _Req, _State) -> ok.

clean_msg(Msg) ->
    {[{<<"name">>, Name2}, {<<"msg">>, Msg2}]} = jiffy:decode(Msg),
    jiffy:encode({[{<<"name">>, Name2}, {<<"msg">>, escape(Msg2)}]}).

escape(B) when is_binary(B) -> escape(binary_to_list(B), []);
escape(A) when is_atom(A)   -> escape(atom_to_list(A), []);
escape(S) when is_list(S)   -> escape(S, []).

escape([], Acc)          -> list_to_binary(lists:reverse(Acc));
escape("<" ++ Rest, Acc) -> escape(Rest, lists:reverse("&lt;", Acc));
escape(">" ++ Rest, Acc) -> escape(Rest, lists:reverse("&gt;", Acc));
escape("&" ++ Rest, Acc) -> escape(Rest, lists:reverse("&amp;", Acc));
escape([C | Rest], Acc)  -> escape(Rest, [C | Acc]).
