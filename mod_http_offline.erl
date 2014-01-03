%% To move into the ejabberd directory
%% cp sudo cp mod_http_offline.beam /lib/ejabberd/ebin

%% To view the log
%% sudo emacs /var/log/ejabberd/ejabberd.log

-module(mod_http_offline).
 
-author("Joseph Martin").
 
%% Every ejabberd module implements the gen_mod behavior
%% The gen_mod behavior requires two functions: start/2 and stop/1
-behaviour(gen_mod).
 
%% public methods for this module
-export([start/2, stop/1, create_message/3]).
 
%% included for writing to ejabberd log file
-include("ejabberd.hrl").
 
%% ejabberd functions for JID manipulation called jlib.
-include("jlib.hrl").
 
start(_Host, _Opt) -> 
        ?INFO_MSG("mod_http_offline loading", []),
        %send("Test Push"),
        ejabberd_hooks:add(offline_message_hook, _Host, ?MODULE, create_message, 50).   
 
 
stop (_Host) -> 
        ?INFO_MSG("stopping mod_http_offline", []),
        ejabberd_hooks:delete(offline_message_hook, _Host, ?MODULE, create_message, 50).
 
 
create_message(_From, _To, Packet) ->
        Type = xml:get_tag_attr_s("type", Packet),
        FromS = xml:get_tag_attr_s("from", Packet),
        ToS = xml:get_tag_attr_s("to", Packet),
        Body = xml:get_path_s(Packet, [{elem, "body"}, cdata]),
        if (Type == "chat") ->
            send(Body,"10","Chime")
        end.
  
% All argument fields expect a string
send(Msg) ->
  send_pn([{alert, Msg}]).
% send a string and and a bagde number
send(Msg, Badge) ->
  send_pn([{alert, Msg}, {badge, Badge}]).
% send a string, a badge number and play a sound
send(Msg, Badge, Sound) ->
  send_pn([{alert, Msg}, {badge, Badge}, {sound, Sound}]).

send_pn(Msg) ->

  % start ssl
    ssl:start(),
  % application:start(ssl),

  % socket configuration, may need to increase the timeout if concurrency becomes an issue
  Address = "gateway.sandbox.push.apple.com",
  % Address = "gateway.push.apple.com",
  Port = 2195,
  Cert = "/Users/joemartin/Desktop/PushNotificationCertificates/PushChatCert.pem",
  Key  = "/Users/joemartin/Desktop/PushNotificationCertificates/PushChatKey.pem",
  Options = [{certfile, Cert}, {keyfile, Key}, {password, "bomber100"}, {mode, binary}, {verify, verify_none}],
  Timeout = 5000,

  case ssl:connect(Address, Port, Options, Timeout) of
    {ok, Socket} ->

      % Convert the device token from hex to int to binary
      Token = "3eca19d72fff06a1ac349a4821d1178c3e0a38aea54631efe07f05b6bea10cec",
      TokenNum = erlang:list_to_integer(Token, 16),
      TokenBin = <<TokenNum:32/integer-unit:8>>,

      % Construct the protocol packet
      PayloadString = create_json(Msg),
      Payload = list_to_binary(PayloadString),
      PayloadLength = byte_size(Payload),
      Packet = <<0:8, 32:16, TokenBin/binary, PayloadLength:16, Payload/binary>>,

      % Send the packet then close the socket
      ssl:send(Socket, Packet),
      ssl:close(Socket),

      % Return the PayloadString (for debugging purposes)
      PayloadString;
    {error, Reason} ->
        ?INFO_MSG("THE SSL CONNECTION FAILED", []),
      Reason
  end.

% helper for creating json
create_json(List) ->
  lists:append(["{\"aps\":{", create_keyvalue(List), "}}"]).
 
create_keyvalue([Head]) ->
  create_pair(Head);

create_keyvalue([Head|Tail]) ->
  lists:append([create_pair(Head), ",", create_keyvalue(Tail)]).
 
create_pair({Key, Value}) ->
  lists:append([add_quotes(atom_to_list(Key)), ":", add_quotes(Value)]).

add_quotes(String) ->
  lists:append(["\"", String, "\""]).