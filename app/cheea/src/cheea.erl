-module(cheea).
-behaviour(application).
-export([start/0, start/2, stop/1]).

start() ->
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),
    application:start(lhttpc),
    application:start(mimetypes),
    application:start(cowboy),
    application:start(gproc),
    application:start(cheea).

start(_Type, _Args) ->
    Dispatch = [
        {'_', [
            {'_', websocket_handler, []}
        ]}
    ],
    cowboy:start_listener(http, 100,
        cowboy_tcp_transport, [{port, 8080}],
        cowboy_http_protocol, [{dispatch, Dispatch}]
    ),
    cowboy:start_listener(https, 100,
        cowboy_ssl_transport, [
            {port, 8443}, {certfile, "priv/ssl/cert.pem"},
            {keyfile, "priv/ssl/key.pem"}, {password, "abc123"}],
        cowboy_http_protocol, [{dispatch, Dispatch}]
    ),
    sendfile:start_link(),
    cheea_sup:start_link().


stop(_State) ->
    sendfile:stop(),
    ok.
