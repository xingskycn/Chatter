%% Erlang module to send a JSON message to apple push notification services (APNs)
%% Author: Joseph Martin
%% Current Sources:
%% - Uwe Arzt: https://uwe-arzt.de/2011/03/04/sending-apple-push-notifications-with-erlang/
%% - This Stackoverflow post: http://stackoverflow.com/questions/1757171/how-to-send-a-push-notification-using-erlang
%% - apns4erl for functional comparison: https://github.com/inaka/apns4erl

-module(apns).
-export([send/1, send/2, send/3]).

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

  % start ssl (which requires crypto to also be started)
  crypto:start(),
  ssl:start(),

  % socket configuration, may need to increase the timeout if concurrency becomes an issue
  Address = "gateway.sandbox.push.apple.com",
  %Address = "gateway.push.apple.com",
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