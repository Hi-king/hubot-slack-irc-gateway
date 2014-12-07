{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response} = require 'hubot'
Irc = require 'irc'
Slack = require 'slack-node'

Options = 
    nick: process.env.HUBOT_IRC_LOGIN_USER
    realName: process.env.HUBOT_IRC_REALNAME
    port: process.env.HUBOT_IRC_PORT
    rooms: process.env.HUBOT_IRC_ROOMS.split(",")
    ignoreUsers: process.env.HUBOT_IRC_IGNORE_USERS?.split(",") or []
    server: process.env.HUBOT_IRC_SERVER
    password: process.env.HUBOT_IRC_LOGIN_PASSWORD
    debug: process.env.HUBOT_IRC_DEBUG?
    userName: process.env.HUBOT_IRC_USERNAME
    slack_token: process.env.HUBOT_SLACK_TOKEN

class SlackIrcGateway extends Adapter
    constructor: (robot) ->
        Options.post_nick = robot.name
        @irc_client = new ConfiguredIrcClient
        @slack_client = new ConfiguredSlackClient
        super(robot)

    run: ->
        @emit "connected"
        self = @
        @irc_client.addListener 'message', (from, to, message) ->
            if !(from) # from undefined user like Bots
                console.log "from bot"
                return
            if from.indexOf(Options.post_nick) != -1
                console.log "from myself"
                return
            console.log "from #{from} to #{to}: #{message}"
            user = self.createUser to, from
            self.receive new TextMessage(user, message)

    send: (envelope, strings...) ->
        channel = envelope.reply_to || envelope.room
        console.log "Send message to #{channel}"
        strings.forEach (str) =>
            console.log str
            @slack_client.send(str, channel)
        console.log "hello"

    # @see https://github.com/nandub/hubot-irc/blob/master/src/irc.coffee
    createUser: (channel, from) ->
        user = @getUserFromId from
        user.name = from
        if channel.match(/^[&#]/)
            user.room = channel
        else
            user.room = null
        user

    # @see https://github.com/nandub/hubot-irc/blob/master/src/irc.coffee
    getUserFromId: (id) ->
        # TODO: Add logic to convert object if name matches
        return @robot.brain.userForId(id) if @robot.brain?.userForId?
        # Deprecated in 3.0.0
        return @userForId id

class ConfiguredSlackClient
    constructor: ->
        @options = Options
        @slack = new Slack(@options.slack_token)

    send: (message, channel) ->
        if not (channel in @options.rooms)
            console.log "ignored channel #{channel}"
            return
        options = {
            channel: channel,
            username: @options.post_nick,
            text: message}
        @slack.api "chat.postMessage", options, (err, response)->
            console.log(response)

class ConfiguredIrcClient extends Irc.Client
    constructor: ->
        options = Options
        client_options =
            userName: options.userName
            realName: options.realName
            password: options.password
            debug: options.debug
            port: options.port
            stripColors: true
            secure: true
            selfSigned: options.fakessl
            certExpired: options.certExpired
            channels: options.rooms
        super options.server, options.nick, client_options

exports.use = (robot) ->
    new SlackIrcGateway robot
