hubot-slack-irc-gateway
=======================

Slack adaptor with irc-gateway for hubot


For who
-------------

  * cannot receive outgoing webhooks
    * probably because of firewall
  * cannot create a hubot's slack account
    * because slack charge to each account

Not for who
-------------

  * can receive outgoing webhooks
    * use [hubot-slack](https://github.com/tinyspeck/hubot-slack)
  * can create account per each hubot
    * use [hubot-irc](https://github.com/nandub/hubot-irc)

Try
-------------

```shell
export HUBOT_IRC_PORT=6667

# settings for slack api
# @see https://api.slack.com/
export HUBOT_SLACK_TOKEN=your_slack_token_here
export HUBOT_IRC_SERVER=your.domain.slack.com

# settings for irc gateway
# @see https://YOUR.DOMAIN.slack.com/account/gateways
export HUBOT_IRC_LOGIN_USER=user_name_for_irc_gateway
export HUBOT_IRC_LOGIN_PASSWORD=password_for_irc_gateway

export HUBOT_IRC_ROOMS="#channel1,#channel2"
bin/hubot -a slack-irc-gateway --name mybot
```

How it works
--------------

  * receive messages using Slack's ircgateway
  * post messages with slack API
    * ircgateway has more strict limitation of use than API
