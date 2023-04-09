# Request Master

## Overview

This library provides a set of extensions for easily encoding, decoding, and sending HTTP requests. The encoding tools support `application/x-www-form-urlencoded`, `multipart/form-data` and `application/json` request formats, using familiar structs and arrays instead of manual string manipulations. The HTTP helper functions also enable sending requests and receiving responses at source, without a separate HTTP asynchronous event.

## Requirements

- GameMaker Studio 2022 / 2.3.7 or above
- (optional) [JSON Struct](https://github.com/dicksonlaw583/JsonStruct) v1.1.0 or higher

If you use GameMaker Studio 2.3.2 - 2.3.6, use [v1.2.2](https://github.com/dicksonlaw583/RequestMaster/releases/tag/v1.2.1).

For GameMaker Studio 2.3.0 and 2.3.1, you can only use [v1.0.x](https://github.com/dicksonlaw583/RequestMaster/releases/tag/v1.0.0) versions of this library, which always require JSON Struct.

## Installation

Get the current asset package and associated documentation from [the releases page](https://github.com/dicksonlaw583/RequestMaster/releases). Simply extract all the scripts to your project.

Once you install the package, you may optionally change the options in `__REQM_CONFIGS__`. The defaults should be appropriate for common JSON-based HTTP APIs.

## Examples

### Fetching from an API Endpoint
```
xhr_get("https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/", {
    params: { appid: 282800, count: 1 },
    done: function(res) {
        show_message("Latest news from 100% Orange Juice: " + res.data.appnews.newsitems[0].title);
    },
    fail: function() {
        show_message("Can't fetch headlines from Steam.");
    }
});
```

### Downloading a File

Note: Due to browser-side JS restrictions, this does not work on HTML5 or OperaGX exports.

```
xhr_download("http://web.archive.org/web/20060821000040im_/http://gamemaker.nl/images/header.jpg", working_directory + "gmlegacy.jpg", {
	done: function(res) {
		sprite_index = sprite_add(res.file, 1, false, false, 0, 0);
	},
	fail: function(res) {
		show_message_async("Failed to download the image!");
	}
});
```
