# Request Master

## Overview

This library provides a set of extensions for easily encoding, decoding, and sending HTTP requests. The encoding tools support `application/x-www-form-urlencoded`, `multipart/form-data` and `application/json` request formats, using familiar structs and arrays instead of manual string manipulations. The HTTP helper functions also enable sending requests and receiving responses at source, without a separate HTTP asynchronous event.

## Requirements

- GameMaker Studio 2.3 Open Beta
- [JSON Struct](https://github.com/dicksonlaw583/JsonStruct)

## Installation

Get the current beta asset package and associated documentation from [the releases page](https://github.com/dicksonlaw583/RequestMaster/releases). Simply extract everything to your project, including the extension and the companion scripts. Once you do that, you may optionally change the options in `__REQM_CONFIGS__`. The defaults should be appropriate for common JSON-based HTTP APIs.

**Reminder**: Don't forget to install and configure [JSON Struct](https://github.com/dicksonlaw583/JsonStruct) if you have not already done so!

## Example

```
xhr_get("https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/", {
	params: { appid: 440, count: 1 },
	done: function(res) {
		show_message_async("Latest news from Team Fortress 2: " + res.data.appnews.newsitems[0].title);
	},
	fail: function() {
		show_message_async("Can't fetch headlines from Steam.");
	}
});
```