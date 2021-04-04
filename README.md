# Request Master v1.1.0

## Overview

This library provides a set of extensions for easily encoding, decoding, and sending HTTP requests. The encoding tools support `application/x-www-form-urlencoded`, `multipart/form-data` and `application/json` request formats, using familiar structs and arrays instead of manual string manipulations. The HTTP helper functions also enable sending requests and receiving responses at source, without a separate HTTP asynchronous event.

## Requirements

- GameMaker Studio 2.3.2 or above
- (optional) [JSON Struct](https://github.com/dicksonlaw583/JsonStruct) v1.0.0 or higher

For GameMaker Studio 2.3.0 and 2.3.1, you can only use v1.0.x versions of this library, which always require JSON Struct.

## Installation

Get the current asset package and associated documentation from [the releases page](https://github.com/dicksonlaw583/RequestMaster/releases). Simply extract everything to your project, including the extension and the companion scripts.

Alternatively, you can also download a ready-to-go version from [the YoYo Marketplace](https://marketplace.yoyogames.com/assets/9443/request-master). Extract everything as usual.

Once you install the package, you may optionally change the options in `__REQM_CONFIGS__`. The defaults should be appropriate for common JSON-based HTTP APIs.

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
