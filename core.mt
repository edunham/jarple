def [=> strToInt] := import("lib/atoi")
def [=> simple__quasiParser] := import("lib/simple")
def [=> makeIRCClient, => connectIRCClient] := import("lib/irc/client",
    [=> Timer])

def nick :Str := "monteBot"

object handler:
    to getNick():
        return nick

    to loggedIn(client):
        client.join("#montebot")

    to privmsg(client, source, channel, message):
        traceln("privmsg", client, source, channel, message)
        escape badSource:
            def `@sourceNick!@sourceUser@@@sourceHost` exit badSource :=
source
            if (message =~ `$nick: @action`):
                switch (action):
                    match `join @newChannel`:
                        client.say(channel, "Okay, joining " + newChannel)
                        client.join(newChannel)

                    match `speak`:
                        client.say(channel, "Hi there!")

                    match `quit`:
                        client.say(channel, "Okay, bye!")
                        client.quit("ma'a tarci pulce")

                    match `kill`:
                        client.say(channel,
                            `$sourceNick: Sorry, I don't know how to do that.
Yet.`)

                    match `list @otherChannel`:
                        escape ej:
                            def users := [k
                                for k => _ in client.getUsers(otherChannel,
ej)]
                            client.say(channel, " ".join(users))
                        catch _:
                            client.say(channel, `I can't see into
$otherChannel`)

                    match `in @{via (strToInt) seconds} say @utterance`:
                        when (Timer.fromNow(seconds)) ->
                            client.say(channel,
                                `$sourceNick: Alarm: "$utterance"`)

                    match _:
                        client.say(channel, `$sourceNick: I don't
understand.`)
        catch err:
            traceln(`Bad privmsg source $source couldn't be matched: $err`)

def client := makeIRCClient(handler)
def ep := makeTCP4ClientEndpoint("irc.freenode.net", 6667)
connectIRCClient(client, ep)

