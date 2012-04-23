-module(cheea_util).
-export([to_hex/1, chat_uid/0]).

chat_uid() ->
    {Meg, Sec, Mic} = now(),
    Now = lists:concat([Meg, Sec, Mic]),
    Rand = random:uniform(2000),
    to_hex(erlang:md5(lists:concat([Now, Rand]))).

to_hex([]) ->
    [];
to_hex(Bin) when is_binary(Bin) ->
    to_hex(binary_to_list(Bin));
to_hex([H|T]) ->
    [to_digit(H div 16), to_digit(H rem 16) | to_hex(T)].

to_digit(N) when N < 10 -> $0 + N;
to_digit(N)             -> $a + N-10.

