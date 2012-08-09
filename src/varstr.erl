%%%----------------------------------------------------------------------
%%% File    : chash.erl
%%% Author  : Ery Lee <ery.lee@gmail.com>
%%% Purpose : String contains variables
%%% Created : 20 Mar. 2011
%%% License : http://www.opengoss.com
%%%
%%% Copyright (C) 2011, www.opengoss.com 
%%%----------------------------------------------------------------------
%%%Example: "My name is ${name}"

-module(varstr).

-created("hejin 2012-7-6").

-import(lists, [reverse/1]).

-export([scan/1, eval/2, eval/3]).

%%%Example: "My name is ${name}" or "My name is $name_id ,$key"

eval(VarStr, VarList) ->
    string:join([val(Token, VarList) || Token <- scan(VarStr)], "").

val("$"++Var = Token, VarList) ->
        str(proplists:get_value(list_to_atom(Var), VarList, Token));
val(Token, _VarList) ->
        Token.

eval(VarStr, VarList, '$') ->
    join([val2(Token, VarList) || Token <- scan(VarStr)], "").

val2("$"++_ = Token, VarList) ->
	str(proplists:get_value(list_to_atom(Token), VarList, Token));
val2(Token, _VarList) ->
	Token.

scan([]) ->
    [];
scan(Expr) ->
    scan_start(Expr, [], []).

scan_start([], Token, Tokens) ->
    Str = reverse(Token),
    reverse([Str|Tokens]);
scan_start([$$|S], Token, Tokens) ->
    Str = reverse(Token),
    {Var, LS} = scan_var(S),
    scan_start(LS, [], [Var, Str|Tokens]);
scan_start([C|S], Token, Tokens) ->
    scan_start(S, [C|Token], Tokens).

scan_var([${|S]) ->
    scan_var1(S, []);
scan_var(S) ->
    scan_var(S, []).

scan_var([C|S], Token) when ((C =< $9) and (C >= $0))
    or ((C =< $Z) and (C >= $A))
    or ((C =< $z) and (C >= $a))
    or ((C == $-) or (C == $_)) ->
    scan_var(S, [C|Token]);
scan_var(S, Token) ->
    Var = [$$ | reverse(Token)],
    {Var, S}.

scan_var1([$}|S], Token) ->
    Var = [$$ | reverse(Token)],
    {Var, S};
scan_var1([C|S], Token) ->
    scan_var1(S, [C|Token]).

str(Val) when is_integer(Val) ->
	integer_to_list(Val);
str(Val) when is_float(Val) ->
	string:join(io_lib:format("~.2f", [Val]),"");
str(Val) when is_list(Val) ->
	Val;
str(Val) when is_binary(Val) ->
	binary_to_list(Val);
str(_Val) ->
	"".
